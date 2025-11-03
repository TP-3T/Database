import { Injectable } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class MapsService {
    private prisma = new PrismaClient();

    /*
    accepts pagination or no pagination so caller can decide how to handle the maps 
    */
    async getAll(page?: number, pageSize?: number) {
        if (!page || !pageSize) {
            return this.prisma.map.findMany({
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

        const skip = (page - 1) * pageSize;

        const [maps, total] = await Promise.all([
            this.prisma.map.findMany({
                skip,
                take: pageSize,
                include: {
                    world_state: true,
                    map_tiles: {
                        include: {
                            tile_data: true,
                        },
                    },
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

    async findBySteamId(steamId: string) {
        return this.prisma.map.findFirst({
            where: {
                steam_id: steamId,
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

    async create(data: {
        steam_id: string;
        map_name: string;
        world_state: {
            pollution: number,
            temperature: number,
            year: number,
            sea_level: number,
        };
        tiles: Array<{
            tile_data_id: number;
            feature: number;
            y_coord: number;
            x_coord: number;
            owner: number;
            label?: string,
        }>;
    }) {
        const worldState = await this.prisma.worldState.create({
            data: data.world_state,
        });

        return this.prisma.map.create({
            data: {
                steam_id: data.steam_id,
                map_name: data.map_name,
                world_state_id: worldState.world_state_id,
                map_tiles: {
                    create: data.tiles,
                },
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

    async onModuleDestroy() {
        await this.prisma.$disconnect();
    }
}
