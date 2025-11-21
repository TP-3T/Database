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
    async create(
        @Body()
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
        return this.mapsService.create(mapData);
    }
}
