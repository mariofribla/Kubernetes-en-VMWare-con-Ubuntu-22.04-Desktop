@echo off
set /p RUTA="Ingrese Ruta para Creación de Estrutura Directorio: "
echo Creando Estrutura en: %RUTA%"
echo "--------------"
echo Creando Directorio Raiz: %RUTA%\VMK8s_Cluster
mkdir %RUTA%\VMK8s_Cluster
echo Creando Directorio Raiz: %RUTA%\VMK8s_Cluster\K8sDNS\VirtualDisk
mkdir %RUTA%\VMK8s_Cluster\K8sDNS\VirtualDisk
echo Creando Directorio Raiz: %RUTA%\VMK8s_Cluster\K8sMaster\VirtualDisk
mkdir %RUTA%\VMK8s_Cluster\K8sMaster\VirtualDisk
echo Creando Directorio Raiz: %RUTA%\VMK8s_Cluster\K8sWorked01\VirtualDisk
mkdir %RUTA%\VMK8s_Cluster\K8sWorked01\VirtualDisk
echo "FIN: Estructura Creada"
dir /b/s %RUTA%\VMK8s_Cluster
EXIT /B 0
