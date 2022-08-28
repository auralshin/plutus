<template>
  <v-row justify="center" class="pa-8">
    <v-row justify="center">
      
        <h1>Cross Chain DEX</h1>
      
    </v-row>
    <v-row justify="center">
      <v-col>
        <v-menu
      top
      close-on-content-click=true
    >
      <template v-slot:activator="{ on, attrs }">
        <v-btn
          color="primary"
          dark
          v-bind="attrs"
          v-on="on"
        >
          {{"Token 1"}}
        </v-btn>
      </template>

      <v-list>
        <v-list-item
          v-for="(item, index) in items"
          :key="index"
          @click="this.setToken1(index)"
        >
          <v-list-item-title>{{ item.title }}</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-menu>
      </v-col>
      <v-col>
        <v-menu
      top
      :close-on-content-click="closeOnContentClick"
    >
      <template v-slot:activator="{ on, attrs }">
        <v-btn
          color="primary"
          dark
          v-bind="attrs"
          v-on="on"
        >
           {{"Token 2"}} 
        </v-btn>
      </template>

      <v-list>
        <v-list-item
          v-for="(item, index) in items"
          :key="index"
          @click="this.setToken2(index)"
        >
          <v-list-item-title>{{ item.title }}</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-menu>
      </v-col>
    </v-row>
  </v-row>
</template>

<script>

  export default {
    data: () => ({
      items: [
        { title: 'Click Me' },
        { title: 'Click Me' },
        { title: 'Click Me' },
        { title: 'Click Me 2' },
      ],
      closeOnContentClick: true,
      token1: "",
      token2: ""
    }),
      setToken1(i) {
        this.token1 = this.items[i].title
        console.log(this.token1)
      },
      setToken2(i) {
        this.data.token2 = this.data.items[i].title
        console.log(this.token2)
      },
      
   
  }
</script>
