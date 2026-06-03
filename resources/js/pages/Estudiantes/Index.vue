<template>
  <AuthenticatedLayout title="Estudiantes">
    <template #header>
      <h2 class="font-semibold text-xl text-gray-800 leading-tight">Gestión de Estudiantes</h2>
    </template>

    <div class="py-12">
      <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
        <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
          <form @submit.prevent="submitEstudiante" enctype="multipart/form-data" class="mb-6 space-y-4">
            <select v-model="form.grado_id" required class="border rounded p-2 w-full">
              <option value="">Seleccione un grado</option>
              <option v-for="g in grados" :key="g.id" :value="g.id">{{ g.nombre }} - {{ g.nivel }}</option>
            </select>
            <input v-model="form.nombres" placeholder="Nombres completos" required class="border rounded p-2 w-full">
            <input v-model="form.dni" placeholder="DNI" required class="border rounded p-2 w-full">
            <input type="file" @change="handleFileUpload" accept="image/*" class="border rounded p-2 w-full">
            <button type="submit" class="bg-green-500 text-white px-4 py-2 rounded">
              {{ editing ? 'Actualizar' : 'Registrar' }}
            </button>
            <button v-if="editing" type="button" @click="cancelEdit" class="bg-gray-500 text-white px-4 py-2 rounded">Cancelar</button>
          </form>

          <table class="w-full border">
            <thead>
              <tr><th class="border p-2">ID</th><th>Nombres</th><th>DNI</th><th>Grado</th><th>Foto</th><th>Acciones</th></tr>
            </thead>
            <tbody>
              <tr v-for="est in estudiantes" :key="est.id">
                <td class="border p-2">{{ est.id }}</td>
                <td class="border p-2">{{ est.nombres }}</td>
                <td class="border p-2">{{ est.dni }}</td>
                <td class="border p-2">{{ est.grado?.nombre }} ({{ est.grado?.nivel }})</td>
                <td class="border p-2">
                  <img v-if="est.foto" :src="'/storage/' + est.foto" width="60" class="rounded">
                  <span v-else>Sin foto</span>
                </td>
                <td class="border p-2 space-x-2">
                  <button @click="edit(est)" class="bg-yellow-500 text-white px-2 py-1 rounded">Editar</button>
                  <button @click="destroy(est.id)" class="bg-red-500 text-white px-2 py-1 rounded">Eliminar</button>
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

const estudiantes = ref([])
const grados = ref([])
const form = ref({ grado_id: '', nombres: '', dni: '', foto: null })
const editing = ref(false)
const editId = ref(null)

const fetchData = async () => {
  const [resEst, resGrados] = await Promise.all([
    axios.get('/api/estudiantes'),
    axios.get('/api/grados')
  ])
  estudiantes.value = resEst.data
  grados.value = resGrados.data
}

const handleFileUpload = (e) => {
  form.value.foto = e.target.files[0]
}

const submitEstudiante = async () => {
  const data = new FormData()
  data.append('grado_id', form.value.grado_id)
  data.append('nombres', form.value.nombres)
  data.append('dni', form.value.dni)
  if (form.value.foto) data.append('foto', form.value.foto)

  if (editing.value) {
    data.append('_method', 'PUT')
    await axios.post(`/api/estudiantes/${editId.value}`, data, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  } else {
    await axios.post('/api/estudiantes', data, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  }
  resetForm()
  fetchData()
}

const edit = (est) => {
  editing.value = true
  editId.value = est.id
  form.value = {
    grado_id: est.grado_id,
    nombres: est.nombres,
    dni: est.dni,
    foto: null
  }
}

const destroy = async (id) => {
  if (confirm('¿Eliminar estudiante?')) {
    await axios.delete(`/api/estudiantes/${id}`)
    fetchData()
  }
}

const resetForm = () => {
  form.value = { grado_id: '', nombres: '', dni: '', foto: null }
  editing.value = false
  editId.value = null
}

const cancelEdit = () => resetForm()

onMounted(fetchData)
</script>