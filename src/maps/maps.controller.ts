import { Controller, Get, Post, Body, Query, Param } from '@nestjs/common';
import { ApiTags, ApiQuery, ApiParam, ApiBody } from '@nestjs/swagger';
import { MapsService } from './maps.service'

@ApiTags('maps')
@Controller('maps')
export class MapsController {
    constructor(private readonly mapsService: MapsService) { }

    @Get()
    @ApiQuery({ name: 'page', required: false, type: Number })
    @ApiQuery({ name: 'pageSize', required: false, type: Number })
    async getAll(
        @Query('page') page?: string,
        @Query('pageSize') pageSize?: string,
    ) {
        const pageNum = page ? parseInt(page, 10) : undefined;
        const pageSizeNum = pageSize ? parseInt(pageSize, 10) : undefined;
        return this.mapsService.getAll(pageNum, pageSizeNum);
    }

    @Get(':steamId')
    @ApiParam({ name: 'steamId', type: String })
    async findBySteamId(@Param('steamId') steamId: string) {
        return this.mapsService.findBySteamId(steamId);
    }

    @Post()
    async create(
        @Body()
        createMapDto: {
            steam_id: string;
            map_name: string;
            world_state: {
                pollution: number;
                temperature: number;
                year: number;
                sea_level: number;
            };
            tiles: Array<{
                tile_data_id: number;
                feature: number;
                y_coord: number;
                x_coord: number;
                owner: number;
                label?: string;
            }>;
        },
    ) {
        return this.mapsService.create(createMapDto);
    }
}
