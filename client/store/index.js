/* eslint-disable no-console */
import axios from 'axios'
import Web3 from 'web3'
import Web3Modal from 'web3modal'

import * as ABI from './ABI.json'


export const state = () => ({
  address: '',
  score: {},
  defi: {},
  web3: {},
  provider: {},
  connected: false,
  account: null,
  chainId: 0,
  NFTexists: false,
  NFTTokenId: 0,
  snackBarBool: false,
  snackBarText: 'Error Occured',
  nftSVG: ''
})

export const mutations = {
  updateScore (state, payload) {
    state.score = payload.score
    state.address = payload.score.address
  },
  updateDefiScore (state, payload) {
    state.defi = payload.defi
  },
  clearScore (state) {
    state.score = {}
  },
  clearDefiScore (state) {
    state.defi = {}
  },
  updateWeb3 (state, payload) {
    state.web3 = payload.web3
  },
  clearWeb3 (state) {
    state.web3 = {}
  },
  setConnected (state) {
    state.connected = true
  },
  setAccount (state, payload) {
    console.log(state.account ,payload.account)
    state.account = payload.account
  },
  setChainId (state, payload) {
    state.chainId = payload.chainId
  },
  setNFTExists (state, payload) {
    state.NFTexists = payload.NFTexists
    state.NFTTokenId = payload.NFTTokenId
    state.nftSVG = payload.nftSVG
  },
  setSnackBar (state, payload) {
    state.snackBarBool = payload.snackBarBool
    state.snackBarText = payload.snackBarText
  },
  clearAllState (state) {
    state.address = ''
    state.score = {}
    state.defi = {}
    state.web3 = {}
    state.provider = {}
    state.connected = false
    state.account = null
    state.chainId = 0
    state.NFTexists = false
    state.NFTTokenId = 0
    state.snackBarBool = false
    state.snackBarText = 'Error Occured'
    state.nftSVG = ''
  }
}

export const actions = {
  async fetchMatic ({ commit }, payload) {
    commit('clearScore')
    // Value Calculation
    const options = {
        method: 'GET',
        headers: {
          Accept: 'application/json',
          'X-API-Key': 'VxX8WQxuzpZmwSpqT6GR6sdWExQg35jUHBU6RfKVUHhtFOad0U9Wb26mV96hdChg'
        }
      };
      
    const maticBalance = await fetch('https://deep-index.moralis.io/api/v2/address/balance?chain=polygon', options)
        .then(response => response.json())
        .then(response => {return response.balance})
        .catch(err => console.error(err));
    async function maticInUSD() {
        const maticAPI = 'https://api.coingecko.com/api/v3/simple/price?ids=matic-network&vs_currencies=usd'
        return axios.get(maticAPI)
            .then(response => {
                return Object.values(response.data)[0].usd
            })
            .catch((err) => {
                console.error(err)
                return 0
            })
    }
    const rate = await maticInUSD();
    commit('updateScore', { score: ((maticBalance / 10**18 )  * rate) })
  },

  async fetchBNB ({ commit }, payload) {
    commit('clearDefiScore')
    // Value Calculation
    const options = {
        method: 'GET',
        headers: {
          Accept: 'application/json',
          'X-API-Key': 'VxX8WQxuzpZmwSpqT6GR6sdWExQg35jUHBU6RfKVUHhtFOad0U9Wb26mV96hdChg'
        }
      };
    console.log(this.state.account)
    const bscBalance = await fetch(`https://deep-index.moralis.io/api/v2/${this.state.account}/balance?chain=polygon`, options)
    .then(response => response.json())
    .then(response => {return response.balance})
    .catch(err => console.error(err));
    async function bnbInUSD() {
        const bnbAPI = 'https://api.coingecko.com/api/v3/simple/price?ids=binancecoin&vs_currencies=usd'
        return axios.get(bnbAPI)
            .then(response => {
                return Object.values(response.data)[0].usd
            })
            .catch((err) => {
                console.error(err)
                return 0
            })
    }

    const rate = await bnbInUSD()
    console.log(bscBalance, rate, ((bscBalance / 10**18 )*rate))
    commit('updateDefiScore', { defi: ((bscBalance / 10**18 )*rate)})

  },

  async fetchBothScore ({ dispatch }, payload) {
    await dispatch('fetchMatic', payload)
    await dispatch('fetchBNB', payload)
  },

  async web3Connect ({ commit, dispatch }, payload) {
    const providerOptions = {
      /* See Provider Options Section */
    }
    const web3Modal = new Web3Modal({
      cacheProvider: true, // optional
      providerOptions // required
    })
    try {
      const provider = await web3Modal.connect()

      commit('setConnected')

      const web3 = new Web3(provider)
      const accounts = await web3.eth.getAccounts()
      console.log(accounts)
      if (accounts.length > 0) {
        commit('setAccount', { account: accounts[0] })
      }

      await web3.currentProvider.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: '0x4' }]
      })

      const chainId = await web3.eth.getChainId()
      console.log(chainId)
      commit('setChainId', { chainId })

      provider.on('connect', (info) => {
        const chainId = parseInt(info.chainId)
        commit('setChainId', { chainId })
        console.log('connect', info)
      })

      provider.on('accountsChanged', async (accounts) => {
        if (accounts.length > 0) {
          commit('setAccount', accounts[0])
        } else {
          await dispatch('web3Disconnect')
        }
        console.log('accountsChanged')
      })
      provider.on('chainChanged', (chainId) => {
        chainId = parseInt(chainId)
        commit('setChainId', { chainId })
        console.log('chainChanged', chainId)
      })
    } catch (error) {
      console.log(error)
    }
  },

  async web3Disconnect ({ commit, state }) {
    const providerOptions = {
      /* See Provider Options Section */
    }
    const web3Modal = new Web3Modal({
      network: 'rinkeby', // optional
      cacheProvider: true, // optional
      providerOptions // required
    })
    try {
      await web3Modal.connect()

      web3Modal.clearCachedProvider()
      commit('clearAllState')
    } catch (error) {
      console.log(error)
    }
  },

  async addressNFTQuery ({ commit, dispatch, state }, { address }) {
    await dispatch('fetchBothScore', { address })
    if (state.defi.message === undefined || state.defi.message == null) {
      const providerOptions = {
        /* See Provider Options Section */
      }
      const web3Modal = new Web3Modal({
        cacheProvider: true, // optional
        providerOptions // required
      })
      try {
        const provider = await web3Modal.connect()

        const web3 = new Web3(provider)
        const nftContract = new web3.eth.Contract(ABI.abi, ABI.contractAddress)
        const tokenID = await nftContract.methods.isNFTMinted(address).call()
        if (tokenID > 0) {
          const nftSVG = await nftContract.methods.generateImage(tokenID).call()
          console.log('nftSVG')
          console.log(nftSVG)
          console.log(tokenID)
          commit('setNFTExists', { NFTexists: true, NFTTokenId: tokenID, nftSVG })
        } else {
          commit('setNFTExists', { NFTexists: false, NFTTokenId: 0, nftSVG: '' })
        }
      } catch (error) {
        console.log(error)
      }
    }
  },

  async addressNFTUpdate ({ commit, dispatch, state }, { address }) {
    if (state.NFTexists && state.chainId === 4) {
      const providerOptions = {
        /* See Provider Options Section */
      }
      const web3Modal = new Web3Modal({
        cacheProvider: true, // optional
        providerOptions // required
      })
      try {
        const provider = await web3Modal.connect()

        const web3 = new Web3(provider)
        const nftContract = new web3.eth.Contract(ABI.abi, ABI.contractAddress)
        const gasEstimates = await nftContract.methods.updateReputationScore(address, state.defi.defiScore, state.defi.syncBlockNumber.ethereum).estimateGas()
        if (gasEstimates < 150000) {
          const gasPrice = await web3.eth.getGasPrice()
          nftContract.methods.updateReputationScore(address, state.defi.defiScore, state.defi.syncBlockNumber.ethereum).send({ from: state.account, gas: gasEstimates, gasPrice })
            .on('transactionHash', (hash) => {
              console.log('Tx Hash')
              console.log(hash)
            })
            .once('confirmation', (confirmationNumber, receipt) => {
              commit('setSnackBar', { snackBarBool: true, snackBarText: 'Tx Successfully confirmed' })
              dispatch('addressNFTQuery', { address })
              console.log('confirmation')
              console.log(confirmationNumber)
              console.log(receipt)
            })
            .on('receipt', (receipt) => {
              console.log('receipt')
              console.log(receipt)
            })
            .on('error', (error) => {
              console.log('error')
              console.log(error)
              commit('setSnackBar', { snackBarBool: true, snackBarText: error.message })
            })
        }
        console.log(gasEstimates)
      } catch (error) {
        console.log(error)
      }
    } else {
      commit('setSnackBar', { snackBarBool: true, snackBarText: 'NFT does not exist or user on incorrect chain' })
    }
  },
  async getBlockNumber() {
    const API_KEY = process.env.MORALIS_API_KEY
    const headers = {
        headers: {
            "accept": "application/json",
            "X-API-Key": API_KEY
        }
    }
    const currentTimestamp = Date.now()
    const API_URL = `https://deep-index.moralis.io/api/v2/dateToBlock?chain=polygon&date=${currentTimestamp}`
    return axios.get(API_URL, headers)
        .then(response => {
            if (isValidResponse(response)) {
                const result = response.data.block
                return result
            }
        })
        .catch(err => {
            console.error(err)
            return null
        })
},
  async addressNFTMint ({ commit, dispatch, state }, { address }) {
    console.log(state.chainId)
    if (!state.NFTexists && state.chainId === 4) {
      const providerOptions = {
        /* See Provider Options Section */
      }
      const web3Modal = new Web3Modal({
        providerOptions // required
      })
      try {
        const provider = await web3Modal.connect()
        const pvalue = state.defi.defiScore
        const web3 = new Web3(provider)
        console.log(ABI.contractAddress)
        const nftContract = new web3.eth.Contract(ABI.abi, ABI.contractAddress)
        const gasEstimates = await nftContract.methods.mint(state.defi.defiScore, getBlockNumber(), address, state.account).estimateGas()
        if (gasEstimates < 250000) {
          console.log(state.defi.syncBlockNumber.ethereum)
          console.log(address)
          const gasPrice = await web3.eth.getGasPrice()
          nftContract.methods.mint(state.defi.defiScore,getBlockNumber() , address, state.account).send({ from: state.account, gas: gasEstimates, gasPrice })
            .on('transactionHash', (hash) => {
              console.log('Tx Hash')
              console.log(hash)
            })
            .once('confirmation', (confirmationNumber, receipt) => {
              commit('setSnackBar', { snackBarBool: true, snackBarText: 'Tx Successfully confirmed' })
              dispatch('addressNFTQuery', { address })
              console.log('confirmation')
              console.log(confirmationNumber)
              console.log(receipt)
            })
            .on('receipt', (receipt) => {
              console.log('receipt')
              console.log(receipt)
            })
            .on('error', (error) => {
              console.log('error')
              console.log(error)
              commit('setSnackBar', { snackBarBool: true, snackBarText: error.message })
            })
        }
        console.log(gasEstimates)
      } catch (error) {
        console.log(error)
      }
    } else {
      commit('setSnackBar', { snackBarBool: true, snackBarText: 'NFT does not exist or user on incorrect chain' })
    }
  }
}
