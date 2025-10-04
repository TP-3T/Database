/*
  Warnings:

  - You are about to drop the `User` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "public"."BuildingCategory" AS ENUM ('INDUSTRIAL', 'POWER', 'UTILITY');

-- CreateEnum
CREATE TYPE "public"."BuildingType" AS ENUM ('LUMBERMILL', 'MINE', 'FARM', 'DOCK', 'HARBOR', 'COAL', 'HYDRO_DAM', 'TIDAL', 'WIND', 'NUCLEAR', 'SEA_WALL', 'PUMP');

-- CreateEnum
CREATE TYPE "public"."TileType" AS ENUM ('BARREN', 'RIVER', 'PLAINS', 'FOREST', 'SNOW', 'SWAMP', 'DESERT', 'MOUNTAIN', 'LAKE');

-- DropTable
DROP TABLE "public"."User";

-- CreateTable
CREATE TABLE "public"."Player" (
    "id" SERIAL NOT NULL,
    "userName" TEXT NOT NULL,
    "currentBalance" DOUBLE PRECISION NOT NULL,
    "moneyEarned" DOUBLE PRECISION,
    "moneyLost" DOUBLE PRECISION,

    CONSTRAINT "Player_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Game" (
    "id" SERIAL NOT NULL,
    "worldId" INTEGER NOT NULL,

    CONSTRAINT "Game_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."worlds" (
    "id" SERIAL NOT NULL,
    "pollutionLevel" INTEGER NOT NULL,
    "seaLevel" INTEGER NOT NULL,
    "temperature" INTEGER NOT NULL,
    "year" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "worlds_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Map" (
    "id" SERIAL NOT NULL,
    "worldId" INTEGER NOT NULL,

    CONSTRAINT "Map_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."BuildingBase" (
    "id" SERIAL NOT NULL,
    "type" "public"."BuildingType" NOT NULL,
    "category" "public"."BuildingCategory" NOT NULL,
    "costWorkers" INTEGER,
    "costMoney" DOUBLE PRECISION,
    "pollutionProduced" INTEGER,
    "populationProduced" INTEGER,
    "moneyProduced" DOUBLE PRECISION,

    CONSTRAINT "BuildingBase_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Building" (
    "id" SERIAL NOT NULL,
    "buildingBaseId" INTEGER NOT NULL,
    "ownerId" INTEGER,
    "tileId" INTEGER,
    "upgradeLevel" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Building_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Tile" (
    "id" SERIAL NOT NULL,
    "x_coordinate" INTEGER NOT NULL,
    "y_coordinate" INTEGER NOT NULL,
    "tileType" "public"."TileType" NOT NULL DEFAULT 'PLAINS',
    "elevation" INTEGER NOT NULL,
    "label" TEXT,
    "ownerId" INTEGER,
    "mapId" INTEGER NOT NULL,

    CONSTRAINT "Tile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Turn" (
    "id" SERIAL NOT NULL,
    "number" INTEGER NOT NULL,
    "gameId" INTEGER NOT NULL,

    CONSTRAINT "Turn_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."WorldChange" (
    "id" SERIAL NOT NULL,
    "pollutionLevel" INTEGER,
    "seaLevel" INTEGER,
    "temperature" INTEGER,
    "year" TIMESTAMP(3),
    "turnId" INTEGER NOT NULL,

    CONSTRAINT "WorldChange_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."TileChange" (
    "id" SERIAL NOT NULL,
    "buildingId" INTEGER,
    "tileType" "public"."TileType",
    "elevation" INTEGER,
    "label" TEXT,
    "ownerId" INTEGER,
    "turnId" INTEGER NOT NULL,
    "tileId" INTEGER NOT NULL,

    CONSTRAINT "TileChange_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Game_worldId_key" ON "public"."Game"("worldId");

-- CreateIndex
CREATE UNIQUE INDEX "Map_worldId_key" ON "public"."Map"("worldId");

-- CreateIndex
CREATE UNIQUE INDEX "BuildingBase_type_key" ON "public"."BuildingBase"("type");

-- CreateIndex
CREATE UNIQUE INDEX "Building_tileId_key" ON "public"."Building"("tileId");

-- CreateIndex
CREATE UNIQUE INDEX "Tile_mapId_x_coordinate_y_coordinate_key" ON "public"."Tile"("mapId", "x_coordinate", "y_coordinate");

-- AddForeignKey
ALTER TABLE "public"."Game" ADD CONSTRAINT "Game_worldId_fkey" FOREIGN KEY ("worldId") REFERENCES "public"."worlds"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Map" ADD CONSTRAINT "Map_worldId_fkey" FOREIGN KEY ("worldId") REFERENCES "public"."worlds"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Building" ADD CONSTRAINT "Building_buildingBaseId_fkey" FOREIGN KEY ("buildingBaseId") REFERENCES "public"."BuildingBase"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Building" ADD CONSTRAINT "Building_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "public"."Player"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Building" ADD CONSTRAINT "Building_tileId_fkey" FOREIGN KEY ("tileId") REFERENCES "public"."Tile"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Tile" ADD CONSTRAINT "Tile_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "public"."Player"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Tile" ADD CONSTRAINT "Tile_mapId_fkey" FOREIGN KEY ("mapId") REFERENCES "public"."Map"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Turn" ADD CONSTRAINT "Turn_gameId_fkey" FOREIGN KEY ("gameId") REFERENCES "public"."Game"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."WorldChange" ADD CONSTRAINT "WorldChange_turnId_fkey" FOREIGN KEY ("turnId") REFERENCES "public"."Turn"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TileChange" ADD CONSTRAINT "TileChange_buildingId_fkey" FOREIGN KEY ("buildingId") REFERENCES "public"."BuildingBase"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TileChange" ADD CONSTRAINT "TileChange_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "public"."Player"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TileChange" ADD CONSTRAINT "TileChange_turnId_fkey" FOREIGN KEY ("turnId") REFERENCES "public"."Turn"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TileChange" ADD CONSTRAINT "TileChange_tileId_fkey" FOREIGN KEY ("tileId") REFERENCES "public"."Tile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
