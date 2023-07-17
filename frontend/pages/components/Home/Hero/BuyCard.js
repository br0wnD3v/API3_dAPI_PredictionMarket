import { Box, Flex, Spacer, Text } from "@chakra-ui/react";

import { tradingABI, tradingAddress } from "@/information/constants";

import { useContractRead } from "wagmi";

import { useEffect, useState } from "react";

export default function BuyCard({ data }) {
  const [dataFetched, setDataFetched] = useState(null);
  const id = data;

  const contractRead = useContractRead({
    address: tradingAddress,
    abi: tradingABI,
    functionName: "getPrediction",
    args: [id],
    onSuccess(data) {
      console.log("Success", data);
      setDataFetched(data);
    },
  });
  const api3AccentGreen = "#5ACAAF";

  return (
    <>
      <Box
        bgColor="#F3F3F3"
        minW="30%"
        minH="200px"
        float="left"
        m="1.65%"
        borderRadius={10}
        boxShadow="0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19)"
      >
        {dataFetched ? (
          <>
            <Flex direction="column">
              <Flex direction="row" m={2} color={api3AccentGreen}>
                <Text>{""}</Text>
                <Spacer />
                <Text>{id}</Text>
              </Flex>
            </Flex>
          </>
        ) : null}
      </Box>
    </>
  );
}
