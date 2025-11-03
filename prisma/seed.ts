import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient();

async function main() 
{
    const worldState = await prisma.worldState.create ({
        data: {
            pollution: 67,
            temperature: 25,
            year: 1900,
            sea_level: 3,
        },
    });

    const tileOne = await prisma.tileData.create({
        data: {
            tile_type: 1,
            elevation: 8,
        },
    });

    const tileTwo = await prisma.tileData.create({
        data: {
            tile_type: 2,
            elevation: 3,
        },
    });

    const tileThree = await prisma.tileData.create({
        data: {
            tile_type: 3,
            elevation: 10,
        },
    });

    const map = await prisma.map.create({
        data: {
            steam_id: '0:0:1129392',
            map_name: 'de_dust2',
            world_state_id: worldState.world_state_id,
            map_tiles: {
                create: [
                    { tile_data_id: tileOne.tile_data_id, feature: 0, y_coord: 0, x_coord: 0, owner: 1, label: "spawn" },
                    { tile_data_id: tileTwo.tile_data_id, feature: 1, y_coord: 0, x_coord: 1, owner: 1, label: null },
                    { tile_data_id: tileThree.tile_data_id, feature: 2, y_coord: 1, x_coord: 0, owner: 1, label: "hill" },
                ]
            }
        }
    });

    console.log('Created:', { worldState, map });
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });