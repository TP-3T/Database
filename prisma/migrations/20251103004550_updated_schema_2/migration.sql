/*
  Warnings:

  - The primary key for the `Feature` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `name` on the `Feature` table. All the data in the column will be lost.
  - The primary key for the `Map` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `MapName` on the `Map` table. All the data in the column will be lost.
  - You are about to drop the column `id` on the `Map` table. All the data in the column will be lost.
  - You are about to drop the column `steamId` on the `Map` table. All the data in the column will be lost.
  - You are about to drop the column `worldId` on the `Map` table. All the data in the column will be lost.
  - The primary key for the `MapTile` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `id` on the `MapTile` table. All the data in the column will be lost.
  - You are about to drop the column `tileId` on the `MapTile` table. All the data in the column will be lost.
  - You are about to drop the column `xCoord` on the `MapTile` table. All the data in the column will be lost.
  - You are about to drop the column `yCoord` on the `MapTile` table. All the data in the column will be lost.
  - The primary key for the `TileType` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `name` on the `TileType` table. All the data in the column will be lost.
  - You are about to drop the `Tile` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `World` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[world_state_id]` on the table `Map` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[tile_data_id]` on the table `MapTile` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[feature_name]` on the table `MapTile` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `feature_name` to the `Feature` table without a default value. This is not possible if the table is not empty.
  - Added the required column `map_name` to the `Map` table without a default value. This is not possible if the table is not empty.
  - Added the required column `steam_id` to the `Map` table without a default value. This is not possible if the table is not empty.
  - Added the required column `world_state_id` to the `Map` table without a default value. This is not possible if the table is not empty.
  - Added the required column `feature_name` to the `MapTile` table without a default value. This is not possible if the table is not empty.
  - Added the required column `tile_data_id` to the `MapTile` table without a default value. This is not possible if the table is not empty.
  - Added the required column `x_coord` to the `MapTile` table without a default value. This is not possible if the table is not empty.
  - Added the required column `y_coord` to the `MapTile` table without a default value. This is not possible if the table is not empty.
  - Added the required column `tile_type_name` to the `TileType` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "public"."Map" DROP CONSTRAINT "Map_worldId_fkey";

-- DropForeignKey
ALTER TABLE "public"."MapTile" DROP CONSTRAINT "MapTile_tileId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Tile" DROP CONSTRAINT "Tile_featureName_fkey";

-- DropForeignKey
ALTER TABLE "public"."Tile" DROP CONSTRAINT "Tile_tileTypeName_fkey";

-- DropIndex
DROP INDEX "public"."Map_worldId_key";

-- DropIndex
DROP INDEX "public"."MapTile_tileId_key";

-- AlterTable
ALTER TABLE "public"."Feature" DROP CONSTRAINT "Feature_pkey",
DROP COLUMN "name",
ADD COLUMN     "feature_name" TEXT NOT NULL,
ADD CONSTRAINT "Feature_pkey" PRIMARY KEY ("feature_name");

-- AlterTable
ALTER TABLE "public"."Map" DROP CONSTRAINT "Map_pkey",
DROP COLUMN "MapName",
DROP COLUMN "id",
DROP COLUMN "steamId",
DROP COLUMN "worldId",
ADD COLUMN     "map_id" SERIAL NOT NULL,
ADD COLUMN     "map_name" TEXT NOT NULL,
ADD COLUMN     "steam_id" TEXT NOT NULL,
ADD COLUMN     "world_state_id" INTEGER NOT NULL,
ADD CONSTRAINT "Map_pkey" PRIMARY KEY ("map_id");

-- AlterTable
ALTER TABLE "public"."MapTile" DROP CONSTRAINT "MapTile_pkey",
DROP COLUMN "id",
DROP COLUMN "tileId",
DROP COLUMN "xCoord",
DROP COLUMN "yCoord",
ADD COLUMN     "feature_name" TEXT NOT NULL,
ADD COLUMN     "map_id" SERIAL NOT NULL,
ADD COLUMN     "tile_data_id" INTEGER NOT NULL,
ADD COLUMN     "x_coord" INTEGER NOT NULL,
ADD COLUMN     "y_coord" INTEGER NOT NULL,
ADD CONSTRAINT "MapTile_pkey" PRIMARY KEY ("map_id");

-- AlterTable
ALTER TABLE "public"."TileType" DROP CONSTRAINT "TileType_pkey",
DROP COLUMN "name",
ADD COLUMN     "tile_type_name" TEXT NOT NULL,
ADD CONSTRAINT "TileType_pkey" PRIMARY KEY ("tile_type_name");

-- DropTable
DROP TABLE "public"."Tile";

-- DropTable
DROP TABLE "public"."World";

-- CreateTable
CREATE TABLE "public"."WorldState" (
    "world_state_id" SERIAL NOT NULL,
    "pollution" INTEGER NOT NULL,
    "temp" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "seaLevel" INTEGER NOT NULL,

    CONSTRAINT "WorldState_pkey" PRIMARY KEY ("world_state_id")
);

-- CreateTable
CREATE TABLE "public"."TileData" (
    "tile_data_id" SERIAL NOT NULL,
    "tile_type_name" TEXT NOT NULL,
    "elevation" INTEGER NOT NULL,

    CONSTRAINT "TileData_pkey" PRIMARY KEY ("tile_data_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "TileData_tile_type_name_key" ON "public"."TileData"("tile_type_name");

-- CreateIndex
CREATE UNIQUE INDEX "Map_world_state_id_key" ON "public"."Map"("world_state_id");

-- CreateIndex
CREATE UNIQUE INDEX "MapTile_tile_data_id_key" ON "public"."MapTile"("tile_data_id");

-- CreateIndex
CREATE UNIQUE INDEX "MapTile_feature_name_key" ON "public"."MapTile"("feature_name");

-- AddForeignKey
ALTER TABLE "public"."Map" ADD CONSTRAINT "Map_world_state_id_fkey" FOREIGN KEY ("world_state_id") REFERENCES "public"."WorldState"("world_state_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."MapTile" ADD CONSTRAINT "MapTile_tile_data_id_fkey" FOREIGN KEY ("tile_data_id") REFERENCES "public"."TileData"("tile_data_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."MapTile" ADD CONSTRAINT "MapTile_feature_name_fkey" FOREIGN KEY ("feature_name") REFERENCES "public"."Feature"("feature_name") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TileData" ADD CONSTRAINT "TileData_tile_type_name_fkey" FOREIGN KEY ("tile_type_name") REFERENCES "public"."TileType"("tile_type_name") ON DELETE RESTRICT ON UPDATE CASCADE;
