<template>
  <div  justify="center" align="center" class="pt-8">
    <v-col v-if="!connected" cols="1">
      <v-btn color="primary" @click="walletConnect">
        Connect
      </v-btn>
    </v-col>
<div v-else>
  
      <v-row justify="center" align="center">
        <v-col cols="12" sm="8" md="6">
  
      <v-card
        class="mx-auto"
        max-width="344"
      >
      <v-row v-if="NFTexists && !overlay" class="text-subtitle-1 mt-8">
              <v-spacer />
              <v-col cols="6">
                <div v-html="nftSVG" />
              </v-col>
              <v-spacer />
            </v-row>
  
      </v-card>
        </v-col>
        <v-col>
          <h2>Your Position : $2300</h2>
          <h2>Chain ID : 137</h2>
          <h2>Chain Name : Polygon</h2>
        </v-col>
      </v-row>
      <v-row  justify="center" align="center">
        <v-btn class="pa-6 ma-6" @click="trial">Mint NFT</v-btn>
        <v-btn class="pa-6 ma-6" @click="updateNFT">Update NFT</v-btn>
      </v-row>
</div>
  </div>
</template>

<script>
import { mapState } from 'vuex'

export default {
  name: 'IndexPage',
  computed: {
    ...mapState(['score','account', 'defi', 'web3', 'connected', 'NFTexists', 'NFTTokenId', 'nftSVG', 'snackBarBool', 'snackBarText'])
  },
  mounted () {
    this.$store.commit('clearAllState')
  },
  data:{
  },
  methods: {
    async walletConnect () {
      this.overlay = true
      await this.$store.dispatch('web3Connect')
        .then((v) => {
          this.overlay = false
        })
        // eslint-disable-next-line no-console
        .catch(err => console.error(err))
    },
    async updateNFT () {
      if (this.NFTexists) {
        this.overlay = true
        await this.$store.dispatch('addressNFTUpdate', { address: this.address })
          .then((v) => {
            this.overlay = false
          })
        // eslint-disable-next-line no-console
          .catch(err => console.error(err))
      }
    },
    async mintNFT () {
      if (!this.NFTexists) {
        this.overlay = true
        console.log('minting')
        await this.$store.dispatch('addressNFTMint', { address: this.address })
          .then((v) => {
            this.overlay = false
          })
        // eslint-disable-next-line no-console
          .catch(err => console.error(err))
      }
    },
    async trial() {
      await this.$store.dispatch('fetchBNB')
    }
  }
}
</script>
