import { PrismaClient } from '@prisma/client';
import { readFileSync } from 'fs';
import { join } from 'path';

const prisma = new PrismaClient();

interface OffsetCoordinates {
    x: number;
    z: number;
}

interface MapTileDataJson {
    Height: number;
    TileType: number;
    OffsetCoordinates: OffsetCoordinates;
}

interface MapJson {
    Name: string;
    Width: number;
    Height: number;
    MapTilesData: MapTileDataJson[];
}

async function main() {
    const jsonPath = join(__dirname, 'seed', 'lower_mainland_test_map_v2.json');
    const raw = readFileSync(jsonPath, 'utf8');
    const data = JSON.parse(raw) as MapJson;

    console.log(`Loading map: ${data.Name}`);
    console.log(`Dimensions: ${data.Width} x ${data.Height}`);
    console.log(`Total tiles in JSON: ${data.MapTilesData.length}`);

    const validTiles = data.MapTilesData.filter(
        (t) => t && t.OffsetCoordinates && t.OffsetCoordinates.x !== undefined && t.OffsetCoordinates.z !== undefined
    );

    console.log(`Valid tiles with coordinates: ${validTiles.length}`);
    console.log('Creating TileData templates...');


    const tileDataMap = new Map<string, { tile_type: number; elevation: number }>();
    
    for (const tile of validTiles) {
        const key = `${tile.TileType}_${tile.Height}`;
        if (!tileDataMap.has(key)) {
            tileDataMap.set(key, { tile_type: tile.TileType, elevation: tile.Height });
        }
    }

    const tileDataTemplates = Array.from(tileDataMap.values());
    console.log(`Creating ${tileDataTemplates.length} unique TileData templates...`);


    await prisma.tileData.createMany({
        data: tileDataTemplates,
        skipDuplicates: true,
    });

    console.log(`Created ${tileDataTemplates.length} TileData templates. Creating WorldState...`);

    const worldState = await prisma.worldState.create({
        data: {
            pollution: 0,
            temperature: 0,
            year: 0,
            sea_level: 0,
        },
    });

    console.log('WorldState created. Looking up TileData IDs...');

    const allTileData = await prisma.tileData.findMany();
    const tileDataLookup = new Map<string, number>();
    
    for (const td of allTileData) {
        const key = `${td.tile_type}_${td.elevation}`;
        tileDataLookup.set(key, td.tile_data_id);
    }

    console.log('Preparing map tiles...');

    const tiles = validTiles.map((t) => {
        const key = `${t.TileType}_${t.Height}`;
        const tile_data_id = tileDataLookup.get(key);
        
        if (!tile_data_id) {
            throw new Error(`No TileData found for tile_type=${t.TileType}, elevation=${t.Height}`);
        }

        return {
            tile_data_id: tile_data_id,
            z_coord: t.OffsetCoordinates.z,
            x_coord: t.OffsetCoordinates.x,
            owner: 1,
            label: null as string | null,
        };
    });

    console.log(`Creating map with ${tiles.length} tiles...`);

    const map = await prisma.map.create({
        data: {
            steam_id: '0:0:1129392',
            map_name: data.Name,
            world_state_id: worldState.world_state_id,
            map_tiles: {
                create: tiles,
            },
        },
        include: {
            world_state: true,
            map_tiles: {
                include: { tile_data: true },
            },
        },
    });

    console.log(`Successfully seeded map: ${data.Name}`);
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });