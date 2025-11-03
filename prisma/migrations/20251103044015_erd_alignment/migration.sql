/*
  Warnings:

  - The primary key for the `MapTile` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `feature_name` on the `MapTile` table. All the data in the column will be lost.
  - You are about to drop the column `tile_type_name` on the `TileData` table. All the data in the column will be lost.
  - You are about to drop the column `seaLevel` on the `WorldState` table. All the data in the column will be lost.
  - You are about to drop the column `temp` on the `WorldState` table. All the data in the column will be lost.
  - You are about to drop the `Feature` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `TileType` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `feature` to the `MapTile` table without a default value. This is not possible if the table is not empty.
  - Added the required column `tile_type` to the `TileData` table without a default value. This is not possible if the table is not empty.
  - Added the required column `sea_level` to the `WorldState` table without a default value. This is not possible if the table is not empty.
  - Added the required column `temperature` to the `WorldState` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "public"."MapTile" DROP CONSTRAINT "MapTile_feature_name_fkey";

-- DropForeignKey
ALTER TABLE "public"."TileData" DROP CONSTRAINT "TileData_tile_type_name_fkey";

-- DropIndex
DROP INDEX "public"."Map_world_state_id_key";

-- DropIndex
DROP INDEX "public"."MapTile_feature_name_key";

-- DropIndex
DROP INDEX "public"."MapTile_tile_data_id_key";

-- DropIndex
DROP INDEX "public"."TileData_tile_type_name_key";

-- AlterTable
ALTER TABLE "public"."MapTile" DROP CONSTRAINT "MapTile_pkey",
DROP COLUMN "feature_name",
ADD COLUMN     "feature" INTEGER NOT NULL,
ALTER COLUMN "map_id" DROP DEFAULT,
ADD CONSTRAINT "MapTile_pkey" PRIMARY KEY ("map_id", "tile_data_id");
DROP SEQUENCE "MapTile_map_id_seq";

-- AlterTable
ALTER TABLE "public"."TileData" DROP COLUMN "tile_type_name",
ADD COLUMN     "tile_type" INTEGER NOT NULL;

-- AlterTable
ALTER TABLE "public"."WorldState" DROP COLUMN "seaLevel",
DROP COLUMN "temp",
ADD COLUMN     "sea_level" INTEGER NOT NULL,
ADD COLUMN     "temperature" INTEGER NOT NULL;

-- DropTable
DROP TABLE "public"."Feature";

-- DropTable
DROP TABLE "public"."TileType";

-- AddForeignKey
ALTER TABLE "public"."MapTile" ADD CONSTRAINT "MapTile_map_id_fkey" FOREIGN KEY ("map_id") REFERENCES "public"."Map"("map_id") ON DELETE RESTRICT ON UPDATE CASCADE;
