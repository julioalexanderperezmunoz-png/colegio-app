<template>
  <AuthenticatedLayout title="Grados">
    <template #header>
      <h2 class="font-semibold text-xl text-gray-800 leading-tight">Gestión de Grados</h2>
    </template>

    <div class="py-12">
      <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
        <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
          <form @submit.prevent="submitForm" class="mb-6 space-y-4">
            <input v-model="form.nombre" placeholder="Nombre del grado" class="border rounded p-2 w-full">
            <input v-model="form.nivel" placeholder="Nivel (Primaria/Secundaria)" class="border rounded p-2 w-full">
            <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded">
              {{ editing ? 'Actualizar' : 'Crear' }}
            </button>
            <button v-if="editing" type="button" @click="cancelEdit" class="bg-gray-500 text-white px-4 py-2 rounded">Cancelar</button>
          </form>

          <table class="w-full border">
            <thead>
              <tr><th class="border p-2">ID</th><th>Nombre</th><th>Nivel</th><th>Acciones</th></tr>
            </thead>
            <tbody>
              <tr v-for="grado in grados" :key="grado.id">
                <td class="border p-2">{{ grado.id }}</td>
                <td class="border p-2">{{ grado.nombre }}</td>
                <td class="border p-2">{{ grado.nivel }}</td>
                <td class="border p-2 space-x-2">
                  <button @click="edit(grado)" class="bg-yellow-500 text-white px-2 py-1 rounded">Editar</button>
                  <button @click="destroy(grado.id)" class="bg-red-500 text-white px-2 py-1 rounded">Eliminar</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </AuthenticatedLayout>
</template>

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue'
import { ref, onMounted } from 'vue'
import axios from 'axios'

const grados = ref([])
const form = ref({ nombre: '', nivel: '' })
const editing = ref(false)
const editId = ref(null)

const fetchGrados = async () => {
  const res = await axios.get('/api/grados')
  grados.value = res.data
}

const submitForm = async () => {
  if (editing.value) {
    await axios.put(`/api/grados/${editId.value}`, form.value)
  } else {
    await axios.post('/api/grados', form.value)
  }
  resetForm()
  fetchGrados()
}

const edit = (grado) => {
  editing.value = true
  editId.value = grado.id
  form.value = { nombre: grado.nombre, nivel: grado.nivel }
}

const destroy = async (id) => {
  if (confirm('¿Eliminar este grado?')) {
    await axios.delete(`/api/grados/${id}`)
    fetchGrados()
  }
}

const resetForm = () => {
  form.value = { nombre: '', nivel: '' }
  editing.value = false
  editId.value = null
}

const cancelEdit = () => resetForm()

onMounted(fetchGrados)
</script>