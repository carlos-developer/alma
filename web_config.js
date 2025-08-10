// Configuración de optimización para ALMA Web
// Este archivo mejora el rendimiento y la experiencia del usuario

// Service Worker para caché offline (opcional para MVP)
if ('serviceWorker' in navigator) {
  window.addEventListener('load', function () {
    // Registrar service worker solo en producción
    if (window.location.hostname !== 'localhost') {
      navigator.serviceWorker.register('/alma/flutter_service_worker.js')
        .then(function(registration) {
          console.log('Service Worker registrado con éxito:', registration.scope);
        })
        .catch(function(error) {
          console.log('Error al registrar Service Worker:', error);
        });
    }
  });
}

// Configuración de rendimiento
// NOTA: No usar window.flutterConfiguration con Flutter 3.x+
// La configuración se maneja ahora a través del engineInitializer

// Detector de conexión para experiencia offline
window.addEventListener('online', function() {
  console.log('Conexión restaurada');
  // Recargar si estaba offline
  if (window.wasOffline) {
    window.location.reload();
  }
});

window.addEventListener('offline', function() {
  console.log('Sin conexión a Internet');
  window.wasOffline = true;
  // Mostrar mensaje al usuario
  showOfflineMessage();
});

function showOfflineMessage() {
  const offlineDiv = document.createElement('div');
  offlineDiv.id = 'offline-message';
  offlineDiv.innerHTML = `
    <div style="position: fixed; top: 0; left: 0; right: 0; 
                background: #ff5252; color: white; padding: 10px; 
                text-align: center; z-index: 9999;">
      Sin conexión a Internet. Algunas funciones pueden no estar disponibles.
    </div>
  `;
  document.body.appendChild(offlineDiv);
  
  // Remover mensaje cuando vuelva la conexión
  window.addEventListener('online', function() {
    const msg = document.getElementById('offline-message');
    if (msg) msg.remove();
  }, { once: true });
}

// Optimización de memoria para dispositivos móviles
if (window.matchMedia('(max-width: 768px)').matches) {
  // Reducir calidad de renderizado en móviles para mejor rendimiento
  window.devicePixelRatio = Math.min(window.devicePixelRatio, 2);
}

// Logger personalizado para producción
const originalConsoleLog = console.log;
const originalConsoleError = console.error;

if (window.location.hostname !== 'localhost') {
  // En producción, reducir logs
  console.log = function(...args) {
    if (args[0] && args[0].includes('Flutter')) {
      originalConsoleLog.apply(console, args);
    }
  };
  
  // Mantener errores pero formateados
  console.error = function(...args) {
    originalConsoleError.apply(console, ['[ALMA Error]', ...args]);
  };
}

// Metricas básicas de rendimiento
window.addEventListener('load', function() {
  // Reportar tiempo de carga
  if (window.performance && window.performance.timing) {
    const loadTime = window.performance.timing.loadEventEnd - 
                    window.performance.timing.navigationStart;
    console.log(`Tiempo total de carga: ${loadTime}ms`);
    
    // Si tarda mucho, sugerir recarga
    if (loadTime > 10000) {
      console.warn('La carga fue lenta. Considera recargar la página.');
    }
  }
});

// Manejo de errores global
window.addEventListener('error', function(event) {
  console.error('Error global capturado:', event.error);
  // En producción, podrías enviar esto a un servicio de tracking
});

// Prevenir zoom accidental en móviles
document.addEventListener('gesturestart', function(e) {
  e.preventDefault();
});

// Export para uso en Flutter si es necesario
window.ALMAConfig = {
  version: '1.0.0',
  environment: window.location.hostname === 'localhost' ? 'development' : 'production',
  baseUrl: '/alma/',
  features: {
    offline: true,
    pwa: false, // Activar en futuras versiones
    analytics: false // Activar cuando se implemente
  }
};