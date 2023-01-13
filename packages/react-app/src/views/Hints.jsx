import { Button, Card, DatePicker, Divider, Input, Progress, Slider, Spin, Switch } from "antd";
import { CheckCircleFilled, ExclamationCircleFilled } from "@ant-design/icons";
import React, { useState } from "react";
import { ethers, utils } from "ethers";

export default function Hints({ tx, writeContracts }) {
  const [data, setData] = useState({ licensePlate: "", parkingZoneId: "" });
  const [authorization, setAuthorization] = useState("");
  const [res, setRes] = useState([]);

  const handleChange = event => {
    setData({ ...data, [event.target.name]: event.target.value });
  };

  const onChangeHandler = event => {
    setAuthorization(event.target.value);
  };

  const handleSubmit = async event => {
    // prevents the submit button from refreshing the page
    event.preventDefault();
    console.log(data);

    const result = await tx(writeContracts.ParkingPermit.verifyParkingPermit(data.licensePlate, data.parkingZoneId));
    console.log(result);
    setRes(result);
    setData({ licensePlate: "", parkingZoneId: "" });
  };

  const handleAuthorized = event => {
    // prevents the submit button from refreshing the page
    event.preventDefault();
    console.log(data);

    const res = tx(writeContracts.ParkingPermit.authorizeRegulator(authorization), update => {
      console.log("📡 Transaction Update:", update);
      if (update && (update.status === "confirmed" || update.status === 1)) {
        console.log(" 🍾 Transaction " + update.hash + " finished!");
        console.log(
          " ⛽️ " +
            update.gasUsed +
            "/" +
            (update.gasLimit || update.gas) +
            " @ " +
            parseFloat(update.gasPrice) / 1000000000 +
            " gwei",
        );
      }
    });
  };

  return (
    <div>
      {/*
        ⚙️ Here is an example UI that displays and sets the purpose in your smart contract:
      */}
      <div style={{ padding: 16, width: 400, margin: "auto", marginTop: "4rem" }}>
        <h2 style={{ padding: 0 }}>DIESE FUNKTION ZUM ADMINPANEL</h2>
        <div>
          <Input
            placeholder={"Adresse"}
            name="address"
            style={{ marginBottom: "1rem" }}
            onChange={event => setAuthorization(event.target.value)}
          />
          <Button onClick={handleAuthorized}>Authorisieren</Button>
        </div>
        <h2 style={{ padding: 0 }}>Überprüfung Parkberechtigung</h2>
        <div style={{ margin: 8, display: "flex", flexDirection: "column" }}>
          <Input
            placeholder={"Kennzeichen"}
            name="licensePlate"
            style={{ marginBottom: "1rem" }}
            value={data.licensePlate}
            onChange={event => handleChange(event)}
          />
          <Input
            placeholder={"Parkzonen-ID"}
            name="parkingZoneId"
            style={{ marginBottom: "1rem" }}
            value={data.parkingZoneId}
            onChange={event => handleChange(event)}
          />
          <div>
            {res[2] === true ? (
              <div style={{ display: "flex", flexDirection: "row", gap: "0.5rem", color: "green" }}>
                <CheckCircleFilled style={{ fontSize: "1.5rem", color: "green" }} />
                <p>Berechtigt</p>
              </div>
            ) : (
              <div style={{ display: "flex", flexDirection: "row", gap: "0.5rem", color: "red" }}>
                <ExclamationCircleFilled style={{ fontSize: "1.5rem", color: "red" }} />
                <p>Nicht berechtigt</p>
              </div>
            )}
          </div>
          <Button
            style={{
              marginTop: 8,
              backgroundColor: "#fdce04",
              color: "black",
              border: "none",
            }}
            onClick={handleSubmit}
          >
            Prüfen
          </Button>
        </div>
      </div>
    </div>
  );
}
