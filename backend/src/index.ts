import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import authRoutes from './routes/auth.routes.js';
import drugRoutes from './routes/drug.routes.js';
import medOrderRoutes from './routes/med-order.routes.js';
import healthCenterRoutes from './routes/health-center.routes.js';
import surveyTicketRoutes from './routes/survey-ticket.routes.js';
import pharmacyRoutes from './routes/pharmacy.routes.js';
import serviceRoutes from './routes/service.routes.js';

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json()); // This replaces bodyParser.json()

app.use('/api/auth', authRoutes);
app.use('/api/drugs', drugRoutes);
app.use('/api/med-orders', medOrderRoutes);
app.use('/api/health-centers', healthCenterRoutes);
app.use('/api/survey-tickets', surveyTicketRoutes);
app.use('/api/pharmacies', pharmacyRoutes);
app.use('/api/services', serviceRoutes);

app.get('/', (req, res) => {
  res.send('CareShield Backend is running!');
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
