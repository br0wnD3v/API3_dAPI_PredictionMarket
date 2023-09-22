import { mhABI } from "@/constants/info";
import { useContractRead } from "wagmi";

export default function RewardCard({ data }) {
  const mhAddress = data["marketHandler"];

  useContractRead({
    address: mhAddress,
    abi: mhABI,
    functionName: "winner",
    onSuccess(data) {
      console.log("The winner is ", data);
    },
  });
}
