import { useContractRead } from "wagmi";

import { Box, Flex, Spacer, Text } from "@chakra-ui/react";

import NoModal from "./NoModal";
import YesModal from "./YesModal";

import { useEffect, useState } from "react";

import {
  convertToDecimal,
  convertUnixEpochToDateString,
  addDecimalTwoPlacesFromRight,
} from "@/helper/functions";

import { tradingABI, tradingAddress } from "@/information/constants";

export default function DashboardCards({ data }) {
  const id = data[0];
  const dataObj = data[1];

  const [direction, setDirection] = useState("");
  const [marketHandler, setMarketHandler] = useState("");
  const [dataFetched, setDataFetched] = useState(null);

  useEffect(() => {
    if (dataFetched) {
      setDirection(dataFetched.isAbove ? "Above" : "Below");
      setMarketHandler(dataFetched.marketHandler);
    }
  }, [dataFetched]);

  useContractRead({
    address: tradingAddress,
    abi: tradingABI,
    functionName: "getPrediction",
    args: [id],
    onSuccess(data) {
      setDataFetched(data);
    },
  });

  return (
    <>
      <Box
        bgColor="#F3F3F3"
        minW="30%"
        minH="240px"
        float="left"
        m="1.65%"
        borderRadius={10}
        boxShadow="0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19)"
      >
        {dataFetched ? (
          <>
            <Flex direction="column" fontFamily="Barlow" align="left" p={4}>
              <Flex direction="row">
                <Text fontSize={22}>{dataFetched.tokenSymbol}</Text>
                <Spacer />
                <Text color="#3BC7A6">{id}</Text>
              </Flex>{" "}
              <Flex direction="row">
                <Text>Deadline : </Text>
                <Text color="#3BC7A6">
                  {"  "}
                  {convertUnixEpochToDateString(dataFetched.deadline)}
                </Text>
              </Flex>
              <Flex direction="row">
                <Text>Target Price : </Text>
                <Text color="#3BC7A6">
                  {"  "}
                  {convertToDecimal(dataFetched.targetPricePoint)}
                </Text>
              </Flex>
              <Flex direction="row">
                <Text>Token Price In USDC : </Text>
                <Text color="#3BC7A6">
                  {addDecimalTwoPlacesFromRight(
                    dataFetched.predictionTokenPrice.toString()
                  )}
                </Text>
              </Flex>
              <Flex mb={4}>
                <Text>
                  Price Predicted To Be{" "}
                  <Text display="inline" color="#3BC7A6">
                    {direction}
                  </Text>{" "}
                  The Target Price.
                </Text>
              </Flex>
              <Text>Current Token Count Of Each Side </Text>
              <Flex direction="row" mt={3}>
                {marketHandler ? (
                  <>
                    <NoModal data={dataObj} />
                    <Spacer />
                    <YesModal data={dataObj} />
                  </>
                ) : null}
              </Flex>
            </Flex>
          </>
        ) : null}
      </Box>
    </>
  );
}
