import axios from "axios";
import * as functions from "firebase-functions";
import { checkAuth } from "../webhook/utils/auth";

export async function sendAirtime(req: any, res: any) {
  try {
    await checkAuth(req); // Verify auth

    const { phoneNumber, amount, network, requestID} = req.body;

    if (!phoneNumber || !amount || !network || !requestID) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const response = await axios.post("https://sandbox.vtpass.com/api/pay", {
      request_id: requestID,
      serviceID: network,
      amount: amount,
      phone: phoneNumber,
    }, {
      headers: {
        "api-key": functions.config().vtpass.apikey,
        "secret-key": functions.config().vtpass.secretkey,
        "Content-Type": "application/json",
      },
    });

    return res.status(200).json({ status: "success", response: response.data });

  } catch (error: any) {
    console.error("sendAirtime error:", error?.response?.data || error.message);
    return res.status(500).json({ error: "Airtime failed", details: error?.response?.data });
  }
}
