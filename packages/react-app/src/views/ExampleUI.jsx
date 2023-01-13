import { Button, Card, DatePicker, Divider, Input, Progress, Slider, Spin, Switch, List } from "antd";
import React, { useState } from "react";
import { ethers, utils } from "ethers";

export default function ExampleUI({ tx, writeContracts }) {
  const [data, setData] = useState({ address: "", licensePlate: "", parkingZoneId: "" });

  const handleChange = event => {
    setData({ ...data, [event.target.name]: event.target.value });
  };

  const handleSubmit = event => {
    // prevents the submit button from refreshing the page
    event.preventDefault();
    console.log(data);

    const result = tx(
      writeContracts.ParkingPermit.residentCarRegistration(data.address, data.licensePlate, data.parkingZoneId, {
        value: utils.parseEther("1"),
      }),
      update => {
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
      },
    );
    setData({ address: "", licensePlate: "", parkingZoneId: "" });
  };

  return (
    <div>
      {/*
        ⚙️ Here is an example UI that displays and sets the purpose in your smart contract:
      */}
      <div style={{ padding: 16, width: 400, margin: "auto", marginTop: "4rem" }}>
        <h2 style={{ padding: 0 }}>Beantragung Bewohnerparkplatz</h2>
        <div style={{ margin: 8, display: "flex", flexDirection: "column" }}>
          <Input
            placeholder={"Wallet-Adresse"}
            name="address"
            style={{ marginBottom: "1rem" }}
            value={data.address}
            onChange={event => handleChange(event)}
          />
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
          <Button
            style={{
              marginTop: 8,
              backgroundColor: "#fdce04",
              color: "black",
              border: "none",
            }}
            onClick={handleSubmit}
          >
            Registrieren
          </Button>
        </div>
      </div>
    </div>
  );
}
