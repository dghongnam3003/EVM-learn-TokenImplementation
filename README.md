# Midterm Project - Token Implementation

This project demonstrates a basic ERC20 and ERC721 token implementation and use cases. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
```

For testing:

- `ERC20`:
```
npx hardhat test ./test/CustomERC20.js
```

- `ERC721`:
```
npx hardhat test ./test/CustomERC721.js
```

To deploy tokens:

- Run the local hardhat network node (don't turn off this terminal as long as you want to deploy and interact with the contracts):
```
npx hardhat node
```

- For `ERC20`:
```
npx hardhat run scripts/deploy.js --network localhost
```

- For `ERC721`:
```
npx hardhat run scripts/deployNFT.js --network localhost
```


To interact with deployed contracts:

- Go the file you want to run (`interact.js` for `ERC20` and `interactNFT.js` for `ERC721`) and put your deployed contract address into the code

- Next, run the command below (based on the token you want to interact):

  - `ERC20`:
  ```
  npx hardhat run scripts/interact.js --network localhost
  ```

  - `ERC721`:
  ```
  npx hardhat run scripts/interactNFT.js --network localhost  
  ```