import { Controller, Get, Post, Body, Query, Param, ParseIntPipe } from '@nestjs/common';
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

    @Get('steamId/:steamId')
    @ApiParam({ name: 'steamId', type: String })
    @ApiQuery({ name: 'page', required: false, type: Number })
    @ApiQuery({ name: 'pageSize', required: false, type: Number })
    async findBySteamId(
        @Param('steamId') steamId: string,
        @Query('page') page?: string,
        @Query('pageSize') pageSize?: string,
    ) {
        const pageNum = page ? parseInt(page, 10) : undefined;
        const pageSizeNum = pageSize ? parseInt(pageSize, 10) : undefined;
        return this.mapsService.findBySteamId(steamId, pageNum, pageSizeNum);
    }

    @Get('mapId/:mapId')
    @ApiParam({ name: 'mapId', type: Number })
    async findByMapId(@Param('mapId', ParseIntPipe) mapId: number) 
    {
        return this.mapsService.findByMapId(mapId);
    }

    @Get('mapName/:mapName')
    @ApiParam({ name: 'mapName', type: String })
    async findByMapName(@Param('mapName') mapName: string)
    {
        return this.mapsService.findByMapName(mapName);
    }

    @Post()
    @ApiQuery({ name: 'steam_id', required: true, type: String })
    @ApiQuery({ name: 'map_name', required: true, type: String })
    async create(
        @Query('steam_id') steamId: string,
        @Query('map_name') mapName: string,
        @Body()
        mapData: {
            MapTilesData: Array<{
                TileType: number;
                OffsetCoordinates: {
                    x: number;
                    z: number;
                };
                Height: number;
            }>;
        },
    ) {
        return this.mapsService.create(steamId, mapName, mapData);
    }
}
