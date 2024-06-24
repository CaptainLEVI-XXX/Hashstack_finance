'use client';

import React, { useState, useEffect } from 'react';
import web3 from '../injector/web3';
import { A_ABI } from "../ABI/impl.js";
import { AV2_ABI } from "../ABI/impl2.js";
import { A_PROXY_ADDRESS } from '../ABI/proxy.js';

const ContractInteraction = () => {
  const [value, setValue] = useState('');
  const [newValue, setNewValue] = useState('');
  const [implementationAddress, setImplementationAddress] = useState('');
  const [ownerAddress, setOwnerAddress] = useState('');
  const [account, setAccount] = useState('');
  const [contract, setContract] = useState(null);
  const [currentABI, setCurrentABI] = useState(A_ABI);

  useEffect(() => {
    const initializeWeb3 = async () => {
      if (window.ethereum) {
        try {
          await window.ethereum.request({ method: 'eth_requestAccounts' });
          const accounts = await web3.eth.getAccounts();
          setAccount(accounts[0] || '');

          const contractInstance = new web3.eth.Contract(currentABI, A_PROXY_ADDRESS);
          setContract(contractInstance);

          window.ethereum.on('accountsChanged', handleAccountChange);
        } catch (error) {
          console.error('Error initializing Web3:', error);
        }
      } else {
        console.log('Please install MetaMask!');
      }
    };

    initializeWeb3();

    return () => {
      if (window.ethereum) {
        window.ethereum.removeListener('accountsChanged', handleAccountChange);
      }
    };
  }, [currentABI]);  // Add currentABI as a dependency

  const handleAccountChange = async (accounts) => {
    if (accounts.length > 0) {
      setAccount(accounts[0]);
      await getValue();
    } else {
      setAccount('');
      setValue('');
    }
  };

  const getValue = async () => {
    if (!contract || !account) {
      console.error('Contract or account not initialized');
      return;
    }
    try {
      const result = await contract.methods.getter().call({ from: account });
      setValue(result);
    } catch (error) {
      console.error('Error fetching value:', error);
      alert('Error fetching value. Check console for details.');
    }
  };

  const setValueOnContract = async () => {
    if (!contract || !account) {
      console.error('Contract or account not initialized');
      return;
    }
    try {
      await contract.methods.setter(newValue).send({ from: account });
      alert('Value set successfully!');
      await getValue();
    } catch (error) {
      console.error('Error setting value:', error);
      alert('Error setting value. Check console for details.');
    }
  };

  const upgradeContract = async () => {
    if (!contract || !account) {
      console.error('Contract or account not initialized');
      return;
    }
    try {
      const initializerSignature = web3.eth.abi.encodeFunctionSignature("init(address)");
      const encodedOwnerAddress = web3.eth.abi.encodeParameter('address', ownerAddress);
      const dataV2 = initializerSignature + encodedOwnerAddress.slice(2);

      await contract.methods.upgradeTo(implementationAddress, dataV2).send({ from: account });
      alert('Contract upgraded successfully!');
      
      // Update the contract instance with the new ABI
      setCurrentABI(AV2_ABI);
      const updatedContract = new web3.eth.Contract(AV2_ABI, A_PROXY_ADDRESS);
      setContract(updatedContract);

    } catch (error) {
      console.error('Error upgrading contract:', error);
      alert('Error upgrading contract. Check console for details.');
    }
  };

  return (
    <div>
      <h2>Contract Interaction</h2>
      <p>Connected Account: {account || 'No account connected'}</p>
      <div>
        <button onClick={getValue}>Get Value</button>
        <p>Value: {value}</p>
      </div>
      <div>
        <input
          type="text"
          value={newValue}
          onChange={(e) => setNewValue(e.target.value)}
          placeholder="Set new value"
        />
        <button onClick={setValueOnContract}>Set Value</button>
      </div>
      <div>
        <input
          type="text"
          value={implementationAddress}
          onChange={(e) => setImplementationAddress(e.target.value)}
          placeholder="New Implementation Address"
        />
        <input
          type="text"
          value={ownerAddress}
          onChange={(e) => setOwnerAddress(e.target.value)}
          placeholder="New Owner Address"
        />
        <button onClick={upgradeContract}>Upgrade Contract</button>
      </div>
    </div>
  );
};

export default ContractInteraction;