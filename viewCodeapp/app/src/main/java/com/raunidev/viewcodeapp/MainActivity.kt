package com.raunidev.viewcodeapp

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Bundle
import android.os.Environment
import android.text.Spannable
import android.text.SpannableString
import android.text.style.ForegroundColorSpan
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.ListView
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.graphics.toColorInt
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.util.regex.Pattern

class MainActivity : AppCompatActivity() {

    private lateinit var btnAbrirPasta: Button
    private lateinit var listaArquivos: ListView
    private lateinit var tvCodigoFonte: TextView
    private var arquivosEncontrados = mutableListOf<File>()

    companion object {
        private const val REQUEST_PERMISSION = 100
        private const val MAX_FILE_SIZE = 500 * 1024 // 500 KB para evitar OOM no tablet
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // 1. Vinculando os elementos do XML com o Kotlin
        btnAbrirPasta = findViewById(R.id.btnAbrirPasta)
        listaArquivos = findViewById(R.id.listaArquivos)
        tvCodigoFonte = findViewById(R.id.tvCodigoFonte)

        // 2. Ação do botão: Pedir permissão e abrir pasta
        btnAbrirPasta.setOnClickListener {
            if (verificarPermissao()) {
                abrirSeletorDePasta()
            }
        }

        // 3. Ação ao clicar em um arquivo na lista
        listaArquivos.setOnItemClickListener { _, _, position, _ ->
            val arquivoSelecionado = arquivosEncontrados[position]
            lerEPintarArquivo(arquivoSelecionado)
        }
    }

    // Método educativo: Verifica se temos permissão para ler o tablet
    private fun verificarPermissao(): Boolean {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                REQUEST_PERMISSION
            )
            return false
        }
        return true
    }

    // Callback para quando o usuário aceita ou recusa a permissão
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_PERMISSION) {
            if ((grantResults.isNotEmpty()) && (grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                abrirSeletorDePasta()
            } else {
                Toast.makeText(this, "Permissão necessária para ler os arquivos", Toast.LENGTH_LONG).show()
            }
        }
    }

    // Abre um gerenciador de arquivos simples para escolher a pasta
    private fun abrirSeletorDePasta() {
        val pastaRaiz = Environment.getExternalStorageDirectory()
        // Usamos Coroutines para não travar a tela enquanto busca os arquivos
        lifecycleScope.launch {
            btnAbrirPasta.isEnabled = false
            btnAbrirPasta.text = "Buscando..."
            
            carregarArquivosDaPasta(pastaRaiz)
            
            btnAbrirPasta.isEnabled = true
            btnAbrirPasta.text = "Abrir Pasta"
        }
    }

    // Lê os arquivos da pasta e filtra pelas linguagens desejadas (Executa em background)
    private suspend fun carregarArquivosDaPasta(pasta: File) {
        withContext(Dispatchers.IO) {
            arquivosEncontrados.clear()
            if (pasta.exists() && pasta.isDirectory) {
                try {
                    pasta.walkTopDown()
                        .maxDepth(4) // Limitamos a profundidade para ser mais rápido no tablet
                        .forEach { arquivo ->
                            val nome = arquivo.name.lowercase()
                            if (arquivo.isFile && (nome.endsWith(".dart") || nome.endsWith(".py") || nome.endsWith(".txt"))) {
                                arquivosEncontrados.add(arquivo)
                            }
                        }
                } catch (_: Exception) {
                    withContext(Dispatchers.Main) {
                        Toast.makeText(this@MainActivity, "Erro ao acessar pastas", Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }

        // Atualiza a ListView na Main Thread
        val nomesArquivos = arquivosEncontrados.map { it.name }
        val adapter = ArrayAdapter(this, android.R.layout.simple_list_item_1, nomesArquivos)
        listaArquivos.adapter = adapter
        
        if (arquivosEncontrados.isEmpty()) {
            Toast.makeText(this, "Nenhum arquivo compatível encontrado", Toast.LENGTH_SHORT).show()
        }
    }

    // Lê o texto do arquivo e aplica as cores
    private fun lerEPintarArquivo(arquivo: File) {
        // Verificação de segurança para o tablet não travar com arquivos gigantes
        if (arquivo.length() > MAX_FILE_SIZE) {
            val tamanhoKB = arquivo.length() / 1024
            val mensagem = "Arquivo muito grande (%d KB).\nO limite para este dispositivo é 500 KB.".format(tamanhoKB)
            tvCodigoFonte.text = mensagem
            return
        }

        try {
            val textoBruto = arquivo.readText()
            tvCodigoFonte.text = aplicarCoresVSCode(textoBruto)
        } catch (e: Exception) {
            tvCodigoFonte.text = "Erro ao ler o arquivo:\n${e.message}"
        }
    }

    // Método educativo: Função personalizada para pintar o texto baseado no VS Code
    private fun aplicarCoresVSCode(texto: String): SpannableString {
        val spannable = SpannableString(texto)

        // Definindo as cores da paleta VS Code usando o KTX
        val corPalavraChave = "#569CD6".toColorInt() // Azul
        val corString = "#CE9178".toColorInt()       // Laranja/Rosa
        val corComentario = "#6A9955".toColorInt()   // Verde Escuro

        // 1. Pintar palavras-chave (Ex: class, fun, def, var, import)
        val keywords = "\\b(class|def|fun|var|val|final|import|if|else|for|while|return|void)\\b"
        val matcherKeyword = Pattern.compile(keywords).matcher(texto)
        while (matcherKeyword.find()) {
            spannable.setSpan(
                ForegroundColorSpan(corPalavraChave),
                matcherKeyword.start(),
                matcherKeyword.end(),
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
            )
        }

        // 2. Pintar Strings (Tudo entre aspas duplas ou simples)
        val strings = "\"([^\"]*)\"|'([^']*)'"
        val matcherString = Pattern.compile(strings).matcher(texto)
        while (matcherString.find()) {
            spannable.setSpan(
                ForegroundColorSpan(corString),
                matcherString.start(),
                matcherString.end(),
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
            )
        }

        // 3. Pintar Comentários (Iniciados por // ou #)
        val comments = "(//.*)|(#.*)"
        val matcherComment = Pattern.compile(comments).matcher(texto)
        while (matcherComment.find()) {
            spannable.setSpan(
                ForegroundColorSpan(corComentario),
                matcherComment.start(),
                matcherComment.end(),
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
            )
        }

        return spannable
    }
}