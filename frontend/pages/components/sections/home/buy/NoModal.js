import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalFooter,
  ModalBody,
  ModalCloseButton,
  Button,
  useDisclosure,
} from "@chakra-ui/react";

import { mhABI } from "@/information/constants";

import { usePrepareContractWrite, useContractWrite } from "wagmi";

export default function NoModal({ mhAddress }) {
  const { isOpen, onOpen, onClose } = useDisclosure();

  return (
    <>
      <Button bgColor="red.400" onClick={onOpen}>
        No
      </Button>{" "}
      <Modal isOpen={isOpen} onClose={onClose}>
        <ModalOverlay />
        <ModalContent>
          <ModalHeader></ModalHeader>
          <ModalCloseButton />
          <ModalBody>
            {/* Your modal content for Modal 2 */}
            This is Modal 2 content.
          </ModalBody>
          <ModalFooter>
            <Button colorScheme="blue" mr={3} onClick={onClose}>
              Close
            </Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
}
