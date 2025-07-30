import * as functions from "firebase-functions";
import axios from "axios";
import {checkAuth} from "../webhook/utils/auth";

export async function verifyMerchant(req: any, res: any) {

  try {
    await checkAuth(req);

    const {serviceID, smartCard} = req.body;

    if (!serviceID || !smartCard) {
      return res.status(400).json({error: "Missing required fields"});
    }

    const response = await axios.post("https://sandbox.vtpass.com/api/merchant-verify", {
      serviceID: serviceID,
      billersCode: smartCard,
    }, {
      headers: {
        "username": functions.config().vtpass.username,
        "password": functions.config().vtpass.password,
        "Content-Type": "application/json",
      },
    });
    return {status: "success", data: response.data};
  } catch (error: any) {
    console.error("Verify Merchant Error:", error?.response?.data || error.message);
    throw new functions.https.HttpsError("internal", "verify failed", error?.response?.data);
  }
}


