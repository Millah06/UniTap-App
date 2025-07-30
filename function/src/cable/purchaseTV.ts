import * as functions from "firebase-functions";
import axios from "axios";
import {checkAuth} from "../webhook/utils/auth";

export async function purchaseTV(req: any, res: any) {
  try {
    await checkAuth(req);

    const {requestID, serviceID, phoneNumber, variationCode, subscriptionType, smartCard} = req.body;

    if (!phoneNumber || !serviceID || !requestID || !variationCode || !subscriptionType) {
      return res.status(400).json({ error: "Missing required fields" });
      }

    const response = await axios.post("https://vtpass.com/api/pay", {
      request_id: requestID,
      serviceID: serviceID,
      billersCode: smartCard,
      variation_code: variationCode,
      phone: phoneNumber,
      subscription_type: subscriptionType,
      }, {
        headers: {
          "username": functions.config().vtpass.username,
          "password": functions.config().vtpass.password,
          "Content-Type": "application/json",
          },
      });

    return { status: "success", data: response.data };

  } catch (error: any) {
    console.error("Buy Data Error:", error?.response?.data || error.message);
    throw new functions.https.HttpsError('internal', 'Buy Data failed', error?.response?.data);
  }
}


