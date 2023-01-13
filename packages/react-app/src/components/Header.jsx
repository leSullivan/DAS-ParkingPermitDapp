import React from "react";
import { Typography, Image } from "antd";

const { Title, Text } = Typography;

// displays a page header

export default function Header({ link, title, subTitle, imgSrc, ...props }) {
  return (
    <div style={{ display: "flex", justifyContent: "space-between", padding: "1.2rem" }}>
      <div style={{ display: "flex", flexDirection: "column", flex: 1, alignItems: "start" }}>
        <a href={link} target="_blank" rel="noopener noreferrer">
          <Image src={imgSrc} />
        </a>
        <Text type="secondary" style={{ textAlign: "left" }}>
          {subTitle}
        </Text>
      </div>
      {props.children}
    </div>
  );
}

Header.defaultProps = {
  link: "https://github.com/leSullivan/DAS-ParkingPermitDapp",
  title: "Stadt Leipzig",
  imgSrc: "https://static.leipzig.de/typo3conf/ext/mkleipzig/Resources/Public/img/logo.png",
};
