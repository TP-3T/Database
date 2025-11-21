import { PrismaClient } from '@prisma/client';
import { readFileSync } from 'fs';
import { join } from 'path';

const prisma = new PrismaClient();

interface TileJson {
    Feature: string | null;
    TileType: number;
    Owner: number;
    Elevation: number;
    Label: string | null;
}

interface WorldStateJson {
    Pollution: number;
    SeaLevel: number;
    Temp: number;
    Year: number;
}

interface MapJson {
    MapID: number;
    SteamID: string;
    MapName: string;
    WorldState: WorldStateJson;
    MapTile: {
        [x: string]: {
            [z: string]: TileJson;
        }
    }
}

async function main() {
    const jsonPath = join(__dirname, 'seed', 'lower_mainland_clamped_height.json');
    const raw = readFileSync(jsonPath, 'utf8');
    const data = JSON.parse(raw) as MapJson;

    console.log(`Loading map: ${data.MapName} (ID: ${data.MapID})`);
    console.log(`SteamID: ${data.SteamID}`);

    let tileCount = 0;
    for (const x in data.MapTile) {
        tileCount += Object.keys(data.MapTile[x]).length;
    }

    console.log(`Total tiles in JSON: ${tileCount}`);
    console.log('Creating TileData templates...');

    const tileDataMap = new Map<string, { tile_type: number; elevation: number }>();

    for (const xKey in data.MapTile) {
        for (const zKey in data.MapTile[xKey]) {
            const tile = data.MapTile[xKey][zKey];
            const key = `${tile.TileType}_${tile.Elevation}`;
            if (!tileDataMap.has(key)) {
                tileDataMap.set(key, { tile_type: tile.TileType, elevation: tile.Elevation });
            }
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
            pollution: data.WorldState.Pollution,
            temperature: data.WorldState.Temp,
            year: data.WorldState.Year,
            sea_level: data.WorldState.SeaLevel,
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

    const tiles: Array<{
        tile_data_id: number;
        z_coord: number;
        x_coord: number;
        owner: number;
        label: string | null;
        feature: string | null;
    }> = [];

    for (const xKey in data.MapTile) {
        for (const zKey in data.MapTile[xKey]) {
            const tile = data.MapTile[xKey][zKey];
            const key = `${tile.TileType}_${tile.Elevation}`;
            const tile_data_id = tileDataLookup.get(key);

            if (!tile_data_id) {
                throw new Error(`No TileData found for tile_type=${tile.TileType}, elevation=${tile.Elevation}`);
            }

            tiles.push({
                tile_data_id: tile_data_id,
                z_coord: parseInt(zKey, 10),
                x_coord: parseInt(xKey, 10),
                owner: tile.Owner,
                label: tile.Label,
                feature: tile.Feature,
            });
        }
    }

    console.log(`Creating map with ${tiles.length} tiles...`);

    const map = await prisma.map.create({
        data: {
            steam_id: data.SteamID,
            map_name: data.MapName,
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

    console.log(`Successfully seeded map: ${data.MapName}`);
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });