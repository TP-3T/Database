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
        steamId: string,
        mapName: string,
        mapData: {
            MapTilesData: Array<{
                TileType: number;
                OffsetCoordinates: { x: number; z: number };
                Height: number;
            }>;
        },
        worldState?: {
            pollution: number;
            temperature: number;
            year: number;
            sea_level: number;
        },
    ) {
        const invalidTiles = mapData.MapTilesData.filter(
            (t) => !t ||
                !t.OffsetCoordinates ||
                t.OffsetCoordinates.x === undefined ||
                t.OffsetCoordinates.z === undefined ||
                t.TileType === undefined ||
                t.Height === undefined
        );

        if (invalidTiles.length > 0) {
            throw new Error(`Invalid tiles in request: ${invalidTiles.length} malformed tiles found`);
        }

        const tileDataMap = new Map<string, { tile_type: number; elevation: number }>();

        for (const tile of mapData.MapTilesData) {
            const key = `${tile.TileType}_${tile.Height}`;
            if (!tileDataMap.has(key)) {
                tileDataMap.set(key, { tile_type: tile.TileType, elevation: tile.Height });
            }
        }

        await this.prisma.tileData.createMany({
            data: Array.from(tileDataMap.values()),
            skipDuplicates: true,
        });

        const world = await this.prisma.worldState.create({
            data: worldState || {
                pollution: 0,
                temperature: 0,
                year: 0,
                sea_level: 0,
            },
        });

        const allTileData = await this.prisma.tileData.findMany();
        const tileDataLookup = new Map<string, number>();

        for (const td of allTileData) {
            tileDataLookup.set(`${td.tile_type}_${td.elevation}`, td.tile_data_id);
        }

        const mapTiles = mapData.MapTilesData.map((t) => {
            const key = `${t.TileType}_${t.Height}`;
            const tile_data_id = tileDataLookup.get(key);

            if (!tile_data_id) {
                throw new Error(`No TileData found for tile_type=${t.TileType}, elevation=${t.Height}`);
            }

            return {
                tile_data_id,
                z_coord: t.OffsetCoordinates.z,
                x_coord: t.OffsetCoordinates.x,
                owner: 1,
                label: null,
            };
        });

        return this.prisma.map.create({
            data: {
                steam_id: steamId,
                map_name: mapName,
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
