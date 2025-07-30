import * as functions from "firebase-functions";
import express from "express";
import cors from "cors";

import {sendAirtime} from "./airtime/sendAirtime";
import {buyData} from "./data/buyData";
import {verifyMerchant} from "./cable/verifyMerchant";
import {purchaseTV} from "./cable/purchaseTV";
// import other functions here too if needed

const app = express();
app.use(cors({origin: true}));
app.use(express.json());

app.post("/airtime/sendAirtime", sendAirtime);
app.post("/cable/purchaseTV", purchaseTV);
app.post("/cable/verifyMerchant", verifyMerchant);
app.post("/data/buyData", buyData);

// add more like: app.post("/wallet/fund", handleFundWallet)

export const api = functions.https.onRequest(app);



