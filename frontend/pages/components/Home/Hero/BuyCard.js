import { Box, Button, Flex, Spacer, Text } from "@chakra-ui/react";

import { tradingABI, tradingAddress } from "@/information/constants";

import { useContractRead } from "wagmi";

import { useEffect, useState } from "react";

export default function BuyCard({ data }) {
  const [dataFetched, setDataFetched] = useState(null);
  const [amount, setAmount] = useState(0);
  const [direction, setDirection] = useState("");

  const id = data;

  useEffect(() => {
    if (dataFetched) setDirection(dataFetched.isAbove ? "Above" : "Below");
  }, [dataFetched]);

  const contractRead = useContractRead({
    address: tradingAddress,
    abi: tradingABI,
    functionName: "getPrediction",
    args: [id],
    onSuccess(data) {
      console.log(data);
      setDataFetched(data);
    },
  });

  // marketHandler: "0xD8Ea6F3b0A2390675cf1353cef428038E94E23FF"
  function convertToDecimal(bigNumber) {
    const strNumber = bigNumber.toString(); // Convert to string
    const decimalIndex = strNumber.length - 18; // Index to place decimal

    // Insert decimal point at the appropriate index
    const result = [
      strNumber.slice(0, decimalIndex),
      ".",
      strNumber.slice(decimalIndex),
    ].join("");

    // Round the result to 5 decimal places
    const final = result.substring(0, decimalIndex + 6);
    return final;
  }

  function convertUnixEpochToDateString(epoch) {
    const bigEpoch = epoch.toString();

    const date = new Date(parseInt(bigEpoch) * 1000);
    const day = date.getDate().toString().padStart(2, "0");
    const month = (date.getMonth() + 1).toString().padStart(2, "0");
    const year = date.getFullYear().toString();
    const formattedDate = `${day}/${month}/${year}`;

    return formattedDate;
  }

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
              <Flex mb={4}>
                <Text>
                  Price Predicted To Be{" "}
                  <Text display="inline" color="#3BC7A6">
                    {direction}
                  </Text>{" "}
                  The Target Price.
                </Text>
              </Flex>
              <Text>Are You In Favour Of The Prediction?</Text>
              <Flex direction="row" mt={3}>
                <Button bgColor="red.400" onClick={() => handleNoClick()}>
                  No
                </Button>
                <Spacer />
                <Button bgColor="green.400" onClick={() => handleYesClick()}>
                  Yes
                </Button>
              </Flex>
            </Flex>
          </>
        ) : null}
      </Box>
    </>
  );
}
