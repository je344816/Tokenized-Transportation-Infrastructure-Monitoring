# Tokenized Transportation Infrastructure Monitoring System

A blockchain-based system for monitoring and managing transportation infrastructure using Clarity smart contracts on the Stacks blockchain.

## Overview

This system enables the tokenized management of transportation infrastructure assets, including:

- Registration and tracking of infrastructure assets
- Collection and storage of sensor data
- Monitoring of safety thresholds
- Management of alerts for potential issues
- Tracking of maintenance activities

## Smart Contracts

### Asset Registration Contract

The Asset Registration Contract allows for the registration and management of infrastructure assets.

```clarity
(define-public (register-asset (asset-type (string-utf8 50)) (location (string-utf8 100)) (construction-date uint))
  (let
    (
      (new-id (+ (var-get last-asset-id) u1))
    )
    (var-set last-asset-id new-id)
    (map-set assets
      { asset-id: new-id }
      {
        asset-type: asset-type,
        location: location,
        construction-date: construction-date,
        owner: tx-sender,
        active: true
      }
    )
    (ok new-id)
  )
)
