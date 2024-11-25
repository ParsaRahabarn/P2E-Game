// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
interface MatrixErrors {
    enum Errors {
        AccessDenied,
        NotWinner,
        RoundNotEnded,
        RewardAlreadyReceivd,
        AlreadyInitialized
    }
    error Matrix3DErrors(Errors item);
}
