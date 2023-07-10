import {
  FormControl,
  FormLabel,
  Input,
  Select,
  Box,
  FormErrorMessage,
  Button,
} from "@chakra-ui/react";

import { usdcAddress, usdcABI } from "@/information/constants";
import {
  usePrepareContractWrite,
  useContractWrite,
  useContractRead,
  useAccount,
} from "wagmi";
import { tradingAddress } from "@/information/constants";

import { useEffect, useState } from "react";

export default function Create() {
  const { address } = useAccount();

  const [error, setError] = useState("");

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [startOperation, setStartOperation] = useState(false);
  const [approved, setApproved] = useState(false);

  const [tokenType, setTokenType] = useState("ETH");
  const [dueDate, setDueDate] = useState(null);
  const [targetPrice, setTargetPrice] = useState(null);
  const [isAbove, setIsAbove] = useState(false);

  const { config, error: contractWriteError } = usePrepareContractWrite({
    address: usdcAddress,
    abi: usdcABI,
    functionName: "approve",
    args: [tradingAddress, 50000000n],
  });

  // Get the write function
  const {
    data: writeData,
    isLoading: writeLoading,
    write,
  } = useContractWrite(config);

  useEffect(() => {
    if (startOperation) {
      write();
    }
  }, [startOperation]);

  const handleSubmit = (e) => {
    e.preventDefault();

    setIsSubmitting(true);
    // validate form data
    if (!dueDate || !tokenType || !targetPrice || !isAbove) {
      setError("Please fill out all required fields.");
      setIsSubmitting(false);
      return;
    }
    const dueDateObject = new Date(dueDate);
    const currentDateObject = new Date();
    if (dueDateObject <= currentDateObject) {
      setError("Due date must be in the future.");
      setIsSubmitting(false);
      return;
    }
    const unixEpochTime = Math.floor(dueDateObject.getTime() / 1000).toString();
    setDueDate(unixEpochTime);

    setError("");

    setStartOperation(true);
  };

  return (
    <>
      <Box align="center" justify="center" pt={5}>
        <Box w="50%" border="2px solid black" borderRadius={10} p={10}>
          <form onSubmit={handleSubmit}>
            <FormControl isRequired isInvalid={error}>
              <FormLabel>Asset To Predict</FormLabel>
              <Select
                disabled={isSubmitting}
                value={tokenType}
                onChange={(e) => setTokenType(e.target.value)}
              >
                <option value="ETH">ETH</option>
                <option value="AAVE">AAVE</option>
                <option value="API3">API3</option>
              </Select>
              <FormLabel mt={5}>Deadline</FormLabel>
              <Input
                disabled={isSubmitting}
                type="date"
                value={dueDate}
                onChange={(e) => setDueDate(e.target.value)}
              />
              <FormLabel mt={5}>Target Price In USD</FormLabel>
              <Input
                placeholder="1000"
                type="number"
                disabled={isSubmitting}
                value={targetPrice}
                onChange={(e) => setTargetPrice(e.target.value)}
              />
              <FormLabel mt={5}>Will Be Above The Target?</FormLabel>
              <Select
                disabled={isSubmitting}
                value={isAbove}
                onChange={(e) => setIsAbove(e.target.value)}
              >
                <option value="true">True</option>
                <option value="false">False</option>
              </Select>
              <Button colorScheme="green" onClick={handleSubmit} mt={5}>
                Create
              </Button>
              <FormErrorMessage>{error}</FormErrorMessage>
            </FormControl>
          </form>
        </Box>
      </Box>
    </>
  );
}
