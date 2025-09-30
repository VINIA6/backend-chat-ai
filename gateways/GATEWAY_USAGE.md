# Como usar a resposta do Gateway N8N no Frontend

## 📋 Formato de Resposta Padronizado

O gateway agora retorna **sempre** um campo `message` com a string única da resposta, facilitando o processamento no frontend.

### ✅ Resposta de Sucesso

```json
{
  "success": true,
  "message": "Ok, entendi. O código SQL que você forneceu está projetado...",
  "data": {
    "output": "Ok, entendi. O código SQL que você forneceu está projetado..."
  },
  "status_code": 200
}
```

### ❌ Resposta de Erro

```json
{
  "success": false,
  "message": "Timeout ao conectar com n8n (>120s)",
  "error": "Timeout ao conectar com n8n (>120s)",
  "data": null
}
```

## 🎯 Uso no Frontend

### JavaScript / TypeScript

```javascript
// Fazer requisição à API
const response = await fetch('/api/v1/messages', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    talk_id: "talk_123",
    content: "Mostre os 200 itens mais vendidos"
  })
});

const result = await response.json();

// Agora é simples! Apenas use o campo 'message'
if (result.success) {
  // Exibir a mensagem ao usuário
  console.log(result.message);  // String única!
  displayMessage(result.message);
} else {
  // Exibir erro
  console.error(result.message);
  showError(result.message);
}
```

### React Example

```jsx
function ChatComponent() {
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(false);

  const sendMessage = async (userMessage) => {
    setLoading(true);
    
    try {
      const response = await fetch('/api/v1/messages', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          talk_id: currentTalkId,
          content: userMessage
        })
      });

      const result = await response.json();

      // Adicionar a resposta às mensagens
      if (result.success) {
        setMessages(prev => [...prev, {
          role: 'assistant',
          content: result.message  // ✅ String única!
        }]);
      } else {
        // Tratar erro
        alert(result.message);
      }
    } catch (error) {
      console.error('Erro na requisição:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      {messages.map((msg, idx) => (
        <div key={idx} className={msg.role}>
          {msg.content}
        </div>
      ))}
    </div>
  );
}
```

## 🔍 Campos Suportados

O método `_extract_message()` tenta extrair a string dos seguintes campos (em ordem):

1. `output` (formato atual do N8N)
2. `message`
3. `text`
4. `response`
5. `result`
6. `answer`
7. `content`

Se nenhum campo for encontrado, retorna a string da resposta completa.

## 🐛 Debug

Se precisar debugar a resposta completa do N8N, use o campo `data`:

```javascript
console.log('Resposta completa do N8N:', result.data);
```

## 🚀 Vantagens

✅ **Simples**: Apenas acesse `result.message`  
✅ **Consistente**: Funciona tanto para sucesso quanto para erro  
✅ **Compatível**: Suporta múltiplos formatos de resposta do N8N  
✅ **Debug**: Mantém a resposta completa no campo `data`
