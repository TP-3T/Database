/*
  Warnings:

  - You are about to drop the column `upgradeLevel` on the `Building` table. All the data in the column will be lost.
  - You are about to drop the column `worldId` on the `Map` table. All the data in the column will be lost.
  - You are about to drop the `tile` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `world` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `worlds` table. If the table is not empty, all the data it contains will be lost.
  - Made the column `moneyProduced` on table `BuildingBase` required. This step will fail if there are existing NULL values in that column.
  - Added the required column `mapId` to the `Game` table without a default value. This is not possible if the table is not empty.
  - Added the required column `name` to the `Map` table without a default value. This is not possible if the table is not empty.
  - Made the column `moneyEarned` on table `Player` required. This step will fail if there are existing NULL values in that column.
  - Made the column `moneyLost` on table `Player` required. This step will fail if there are existing NULL values in that column.

*/
-- DropForeignKey
ALTER TABLE "public"."Game" DROP CONSTRAINT "Game_worldId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Map" DROP CONSTRAINT "Map_worldId_fkey";

-- DropForeignKey
ALTER TABLE "public"."tile" DROP CONSTRAINT "tile_buildingId_fkey";

-- DropForeignKey
ALTER TABLE "public"."tile" DROP CONSTRAINT "tile_ownerId_fkey";

-- DropForeignKey
ALTER TABLE "public"."tile" DROP CONSTRAINT "tile_tileId_fkey";

-- DropForeignKey
ALTER TABLE "public"."tile" DROP CONSTRAINT "tile_turnId_fkey";

-- DropForeignKey
ALTER TABLE "public"."world" DROP CONSTRAINT "world_turnId_fkey";

-- DropIndex
DROP INDEX "public"."Game_worldId_key";

-- DropIndex
DROP INDEX "public"."Map_worldId_key";

-- AlterTable
ALTER TABLE "public"."Building" DROP COLUMN "upgradeLevel";

-- AlterTable
ALTER TABLE "public"."BuildingBase" ALTER COLUMN "moneyProduced" SET NOT NULL;

-- AlterTable
ALTER TABLE "public"."Game" ADD COLUMN     "mapId" INTEGER NOT NULL,
ADD COLUMN     "multiplayer" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable
ALTER TABLE "public"."Map" DROP COLUMN "worldId",
ADD COLUMN     "name" TEXT NOT NULL,
ADD COLUMN     "playerId" INTEGER;

-- AlterTable
ALTER TABLE "public"."Player" ADD COLUMN     "gameId" INTEGER,
ALTER COLUMN "moneyEarned" SET NOT NULL,
ALTER COLUMN "moneyEarned" SET DEFAULT 0.0,
ALTER COLUMN "moneyLost" SET NOT NULL,
ALTER COLUMN "moneyLost" SET DEFAULT 0.0;

-- DropTable
DROP TABLE "public"."tile";

-- DropTable
DROP TABLE "public"."world";

-- DropTable
DROP TABLE "public"."worlds";

-- CreateTable
CREATE TABLE "public"."World" (
    "id" SERIAL NOT NULL,
    "pollutionLevel" INTEGER NOT NULL,
    "seaLevel" INTEGER NOT NULL,
    "temperature" INTEGER NOT NULL,
    "year" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "World_pkey" PRIMARY KEY ("id")
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

-- AddForeignKey
ALTER TABLE "public"."Player" ADD CONSTRAINT "Player_gameId_fkey" FOREIGN KEY ("gameId") REFERENCES "public"."Game"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Game" ADD CONSTRAINT "Game_worldId_fkey" FOREIGN KEY ("worldId") REFERENCES "public"."World"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Game" ADD CONSTRAINT "Game_mapId_fkey" FOREIGN KEY ("mapId") REFERENCES "public"."Map"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Map" ADD CONSTRAINT "Map_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "public"."Player"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."WorldChange" ADD CONSTRAINT "WorldChange_turnId_fkey" FOREIGN KEY ("turnId") REFERENCES "public"."Turn"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TileChange" ADD CONSTRAINT "TileChange_buildingId_fkey" FOREIGN KEY ("buildingId") REFERENCES "public"."Building"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TileChange" ADD CONSTRAINT "TileChange_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "public"."Player"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TileChange" ADD CONSTRAINT "TileChange_turnId_fkey" FOREIGN KEY ("turnId") REFERENCES "public"."Turn"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TileChange" ADD CONSTRAINT "TileChange_tileId_fkey" FOREIGN KEY ("tileId") REFERENCES "public"."Tile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
