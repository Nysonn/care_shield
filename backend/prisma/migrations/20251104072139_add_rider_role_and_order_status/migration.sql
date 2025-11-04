-- AlterTable
ALTER TABLE "MedOrder" ADD COLUMN     "pharmacyId" TEXT,
ADD COLUMN     "riderId" TEXT,
ADD COLUMN     "status" TEXT NOT NULL DEFAULT 'pending';

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "licenseNumber" TEXT,
ADD COLUMN     "role" TEXT NOT NULL DEFAULT 'customer',
ADD COLUMN     "vehicleType" TEXT;

-- CreateTable
CREATE TABLE "Pharmacy" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "district" TEXT NOT NULL DEFAULT 'Mbarara',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Pharmacy_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PharmacyDrug" (
    "id" TEXT NOT NULL,
    "pharmacyId" TEXT NOT NULL,
    "drugId" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "isAvailable" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PharmacyDrug_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Service" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Service_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PharmacyService" (
    "id" TEXT NOT NULL,
    "pharmacyId" TEXT NOT NULL,
    "serviceId" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "isAvailable" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PharmacyService_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OrderService" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "serviceId" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 1,
    "price" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OrderService_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ArchivedOrder" (
    "id" TEXT NOT NULL,
    "originalId" TEXT NOT NULL,
    "stage" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL,
    "archivedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "eta" TEXT NOT NULL,
    "totalAmount" DOUBLE PRECISION NOT NULL,
    "deliveryFee" DOUBLE PRECISION NOT NULL,
    "userId" TEXT NOT NULL,
    "orderData" JSONB NOT NULL,

    CONSTRAINT "ArchivedOrder_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "PharmacyDrug_pharmacyId_idx" ON "PharmacyDrug"("pharmacyId");

-- CreateIndex
CREATE INDEX "PharmacyDrug_drugId_idx" ON "PharmacyDrug"("drugId");

-- CreateIndex
CREATE UNIQUE INDEX "PharmacyDrug_pharmacyId_drugId_key" ON "PharmacyDrug"("pharmacyId", "drugId");

-- CreateIndex
CREATE INDEX "PharmacyService_pharmacyId_idx" ON "PharmacyService"("pharmacyId");

-- CreateIndex
CREATE INDEX "PharmacyService_serviceId_idx" ON "PharmacyService"("serviceId");

-- CreateIndex
CREATE UNIQUE INDEX "PharmacyService_pharmacyId_serviceId_key" ON "PharmacyService"("pharmacyId", "serviceId");

-- CreateIndex
CREATE INDEX "OrderService_orderId_idx" ON "OrderService"("orderId");

-- CreateIndex
CREATE INDEX "OrderService_serviceId_idx" ON "OrderService"("serviceId");

-- CreateIndex
CREATE UNIQUE INDEX "ArchivedOrder_originalId_key" ON "ArchivedOrder"("originalId");

-- CreateIndex
CREATE INDEX "ArchivedOrder_userId_idx" ON "ArchivedOrder"("userId");

-- CreateIndex
CREATE INDEX "MedOrder_pharmacyId_idx" ON "MedOrder"("pharmacyId");

-- CreateIndex
CREATE INDEX "MedOrder_userId_idx" ON "MedOrder"("userId");

-- CreateIndex
CREATE INDEX "MedOrder_riderId_idx" ON "MedOrder"("riderId");

-- CreateIndex
CREATE INDEX "MedOrder_status_idx" ON "MedOrder"("status");

-- AddForeignKey
ALTER TABLE "PharmacyDrug" ADD CONSTRAINT "PharmacyDrug_pharmacyId_fkey" FOREIGN KEY ("pharmacyId") REFERENCES "Pharmacy"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PharmacyDrug" ADD CONSTRAINT "PharmacyDrug_drugId_fkey" FOREIGN KEY ("drugId") REFERENCES "Drug"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PharmacyService" ADD CONSTRAINT "PharmacyService_pharmacyId_fkey" FOREIGN KEY ("pharmacyId") REFERENCES "Pharmacy"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PharmacyService" ADD CONSTRAINT "PharmacyService_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "Service"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OrderService" ADD CONSTRAINT "OrderService_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "MedOrder"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OrderService" ADD CONSTRAINT "OrderService_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "Service"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MedOrder" ADD CONSTRAINT "MedOrder_riderId_fkey" FOREIGN KEY ("riderId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MedOrder" ADD CONSTRAINT "MedOrder_pharmacyId_fkey" FOREIGN KEY ("pharmacyId") REFERENCES "Pharmacy"("id") ON DELETE SET NULL ON UPDATE CASCADE;
