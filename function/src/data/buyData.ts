import axios from "axios";
import * as functions from "firebase-functions";
import {checkAuth} from "../webhook/utils/auth";

export async function buyData(req: any, res: any) {
  try {
    await checkAuth(req); // Verify auth

    const {phoneNumber, variationCode, network, requestID} = req.body;

    if (!phoneNumber || !network || !variationCode || !requestID) {
      return res.status(400).json({error: "Missing required fields"});
    }

    const response = await axios.post("https://sandbox.vtpass.com/api/pay", {
      request_id: requestID,
      serviceID: network,
      variation_code: phoneNumber,
      phone: phoneNumber,
    }, {
      headers: {
        "api-key": functions.config().vtpass.apikey,
        "secret-key": functions.config().vtpass.secretkey,
        "Content-Type": "application/json",
      },
    });

    return res.status(200).json({status: "success", response: response.data});
  } catch (error: any) {
    console.error("buyData error:", error?.response?.data || error.message);
    return res.status(500).json({error: "Data failed",
      details: error?.response?.data});
  }
}
