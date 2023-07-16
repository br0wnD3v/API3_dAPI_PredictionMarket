import {
  FormControl,
  FormLabel,
  Input,
  Select,
  Box,
  FormErrorMessage,
  Button,
} from "@chakra-ui/react";

import {
  usdcAddress,
  usdcABI,
  tradingAddress,
  tradingABI,
} from "@/information/constants";

import {
  usePrepareContractWrite,
  useContractWrite,
  useWaitForTransaction,
} from "wagmi";

import { useEffect, useState } from "react";

import { toast } from "react-toastify";

import { ethers } from "ethers";

export default function Create() {
  const [createdPrediction, setCreatedPrediction] = useState(false);
  const [approved, setApproved] = useState(false);
  const [startOperation, setStartOperation] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const [error, setError] = useState("");

  const [tokenType, setTokenType] = useState("ETH");
  const [dueDate, setDueDate] = useState(null);
  const [basePrice, setBasePrice] = useState(1);
  const [targetPrice, setTargetPrice] = useState(0);
  const [displayTargetPrice, setDisplayTargetPrice] = useState(100);
  const [isAbove, setIsAbove] = useState(true);

  async function timeout(delay) {
    return new Promise((res) => setTimeout(res, delay));
  }

  // CREATION ====================
  function resetVariables() {
    setIsSubmitting(false);
    setTokenType("ETH");
    setDueDate(null);
    setBasePrice(1);
    setTargetPrice(0);
    setDisplayTargetPrice(100);
    setIsAbove(true);
    setApproved(false);
    setCreatedPrediction(false);
    setStartOperation(false);
  }

  useEffect(() => {
    if (createdPrediction) {
      toast.success(
        "Market Created Successfully! Can be viewed in the `Buy` section shortly."
      );
      resetVariables();
    }
  }, [createdPrediction]);

  const { config: createPredictionConfig, error: createPredictionWriteError } =
    usePrepareContractWrite({
      address: tradingAddress,
      abi: tradingABI,
      functionName: "createPrediction",
      args: [tokenType, isAbove, targetPrice, dueDate, basePrice],
    });

  const createPredictionWrite = useContractWrite(createPredictionConfig);

  const waitCreatePrediction = useWaitForTransaction({
    hash: createPredictionWrite.data?.hash,
    onSuccess() {
      console.log("Success Market Creation.");
      setCreatedPrediction(true);
    },
  });

  useEffect(() => {
    async function execute() {
      await timeout(2000);
      createPredictionWrite.write();
    }

    if (approved && !createdPrediction) {
      execute();
    }
  }, [approved]);

  // APPROVAL ====================

  const { config: usdcApprovalConfig, error: usdcApprovalWriteError } =
    usePrepareContractWrite({
      address: usdcAddress,
      abi: usdcABI,
      functionName: "approve",
      args: [tradingAddress, 50000000n],
    });

  const usdcApprovalWrite = useContractWrite(usdcApprovalConfig);

  const waitUsdcApproval = useWaitForTransaction({
    hash: usdcApprovalWrite.data?.hash,
    onSuccess() {
      console.log("Success");
      setApproved(true);
    },
  });

  useEffect(() => {
    if (startOperation) {
      usdcApprovalWrite.write();

      console.log(tokenType);
      console.log(basePrice);
      console.log(dueDate);
      console.log(targetPrice);
      console.log(displayTargetPrice);
      console.log(isAbove);
    }
  }, [startOperation]);

  // =====================

  const handleSubmit = (e) => {
    e.preventDefault();

    setIsSubmitting(true);
    // validate form data
    if (
      !dueDate ||
      !tokenType ||
      !displayTargetPrice ||
      !isAbove ||
      !basePrice
    ) {
      setError("Please fill out all required fields.");
      setIsSubmitting(false);
      return;
    }

    if (basePrice < 1) {
      setError("Please set the base price >= 1.");
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

    const validatedValue = parseFloat(displayTargetPrice).toFixed(5);
    const ethValue = ethers.parseUnits(validatedValue.toString(), "ether");
    const weiValue = ethValue.toString();
    setTargetPrice(weiValue);

    setError("");
    setStartOperation(true);
  };

  return (
    <>
      <Box align="center" justify="center" pt={5} mb={100}>
        <Box w="50%" border="2px solid gray" borderRadius={10} p={10}>
          <form onSubmit={handleSubmit}>
            <FormControl isRequired isInvalid={error}>
              <FormLabel>Asset To Predict</FormLabel>
              <Select
                disabled={isSubmitting}
                value={tokenType}
                onChange={(e) => setTokenType(e.target.value)}
              >
                <option value="AAVE">AAVE</option>
                <option value="API3">API3</option>
                <option value="BTC">BTC</option>
                <option value="ETH">ETH</option>
                <option value="MATIC">MATIC</option>
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
                type="number"
                placeholder="1000.00000"
                step="0.00001"
                disabled={isSubmitting}
                value={displayTargetPrice}
                onChange={(e) => setDisplayTargetPrice(e.target.value)}
              />{" "}
              <FormLabel mt={5}>Will Be Above The Target?</FormLabel>
              <Select
                disabled={isSubmitting}
                value={isAbove}
                onChange={(e) => setIsAbove(e.target.value)}
              >
                <option value="true">True</option>
                <option value="false">False</option>
              </Select>
              <FormLabel mt={5}>Cost Of A Tradable Token In Cents</FormLabel>
              <Input
                type="number"
                placeholder="100"
                disabled={isSubmitting}
                value={basePrice}
                onChange={(e) => setBasePrice(e.target.value)}
              />
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
