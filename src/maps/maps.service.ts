import { Injectable } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class MapsService {
    private prisma = new PrismaClient();

    async getAll(page?: number, pageSize?: number) {
        if (!page || !pageSize) {
            return this.prisma.map.findMany({
                select: {
                    map_id: true,
                    map_name: true,
                    steam_id: true,
                },
            });
        }

        const skip = (page - 1) * pageSize;

        const [maps, total] = await Promise.all([
            this.prisma.map.findMany({
                skip,
                take: pageSize,
                select: {
                    map_id: true,
                    map_name: true,
                    steam_id: true,
                },
            }),
            this.prisma.map.count(),
        ]);

        return {
            data: maps,
            info: {
                total,
                page,
                pageSize,
                numPages: Math.ceil(total / pageSize),
            },
        };
    }

    async findBySteamId(
        steamId: string,
        page?: number,
        pageSize?: number,
    ) {
        if (!page || !pageSize) {
            return this.prisma.map.findMany({
                where: { steam_id: steamId },
                select: {
                    map_id: true,
                    map_name: true,
                    steam_id: true,
                },
            });
        }

        const skip = (page - 1) * pageSize;

        const [maps, total] = await Promise.all([
            this.prisma.map.findMany({
                where: { steam_id: steamId },
                skip,
                take: pageSize,
                select: {
                    map_id: true,
                    map_name: true,
                    steam_id: true,
                },
            }),
            this.prisma.map.count({ where: { steam_id: steamId } }),
        ]);

        return {
            data: maps,
            info: {
                total,
                page,
                pageSize,
                numPages: Math.ceil(total / pageSize),
            },
        };
    }

    async findByMapId(mapId: number) {
        return this.prisma.map.findFirst({
            where: {
                map_id: mapId,
            },
            include: {
                world_state: true,
                map_tiles: {
                    include: {
                        tile_data: true,
                    },
                },
            },
        });
    }

    async findByMapName(mapName: string) {
        return this.prisma.map.findFirst({
            where: {
                map_name: mapName,
            },
            include: {
                world_state: true,
                map_tiles: {
                    include: {
                        tile_data: true,
                    },
                },
            },
        });
    }

    async create(
        mapData: {
            MapID: number;
            SteamID: string;
            MapName: string;
            WorldState: {
                Pollution: number;
                SeaLevel: number;
                Temp: number;
                Year: number;
            };
            MapTile: {
                [x: string]: {
                    [z: string]: {
                        Feature: string | null;
                        TileType: number;
                        Owner: number;
                        Elevation: number;
                        Label: string | null;
                    };
                };
            };
        },
    ) {
        const tileDataMap = new Map<string, { tile_type: number; elevation: number }>();

        for (const xKey in mapData.MapTile) {
            for (const zKey in mapData.MapTile[xKey]) {
                const tile = mapData.MapTile[xKey][zKey];
                
                if (tile.TileType === undefined || tile.Elevation === undefined) {
                    throw new Error(`Invalid tile at position [${xKey}][${zKey}]: missing TileType or Elevation`);
                }

                const key = `${tile.TileType}_${tile.Elevation}`;
                if (!tileDataMap.has(key)) {
                    tileDataMap.set(key, { tile_type: tile.TileType, elevation: tile.Elevation });
                }
            }
        }

        await this.prisma.tileData.createMany({
            data: Array.from(tileDataMap.values()),
            skipDuplicates: true,
        });

        const world = await this.prisma.worldState.create({
            data: {
                pollution: mapData.WorldState.Pollution,
                temperature: mapData.WorldState.Temp,
                year: mapData.WorldState.Year,
                sea_level: mapData.WorldState.SeaLevel,
            },
        });

        const allTileData = await this.prisma.tileData.findMany();
        const tileDataLookup = new Map<string, number>();

        for (const td of allTileData) {
            tileDataLookup.set(`${td.tile_type}_${td.elevation}`, td.tile_data_id);
        }

        const mapTiles: Array<{
            tile_data_id: number;
            z_coord: number;
            x_coord: number;
            owner: number;
            label: string | null;
            feature: string | null;
        }> = [];

        for (const xKey in mapData.MapTile) {
            for (const zKey in mapData.MapTile[xKey]) {
                const tile = mapData.MapTile[xKey][zKey];
                const key = `${tile.TileType}_${tile.Elevation}`;
                const tile_data_id = tileDataLookup.get(key);

                if (!tile_data_id) {
                    throw new Error(`No TileData found for tile_type=${tile.TileType}, elevation=${tile.Elevation}`);
                }

                mapTiles.push({
                    tile_data_id,
                    z_coord: parseInt(zKey, 10),
                    x_coord: parseInt(xKey, 10),
                    owner: tile.Owner,
                    label: tile.Label,
                    feature: tile.Feature,
                });
            }
        }

        return this.prisma.map.create({
            data: {
                steam_id: mapData.SteamID,
                map_name: mapData.MapName,
                world_state_id: world.world_state_id,
                map_tiles: {
                    create: mapTiles,
                },
            },
            include: {
                world_state: true,
                map_tiles: {
                    include: { tile_data: true },
                },
            },
        });
    }

    async onModuleDestroy() {
        await this.prisma.$disconnect();
    }
}
