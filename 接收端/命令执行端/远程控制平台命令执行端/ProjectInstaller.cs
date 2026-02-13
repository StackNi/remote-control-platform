using System;
using System.Collections;
using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace 远程控制平台命令执行端
{
    [RunInstaller(true)]
    public class ProjectInstaller : Installer
    {
        private ServiceProcessInstaller serviceProcessInstaller;
        private ServiceInstaller serviceInstaller;

        public ProjectInstaller()
        {
            InitializeComponent();
        }

        private void InitializeComponent()
        {
            this.serviceProcessInstaller = new ServiceProcessInstaller();
            this.serviceInstaller = new ServiceInstaller();

            this.serviceProcessInstaller.Account = ServiceAccount.LocalSystem;
            this.serviceProcessInstaller.Password = null;
            this.serviceProcessInstaller.Username = null;

            this.serviceInstaller.ServiceName = "RemoteControlCmdExecutor";
            this.serviceInstaller.DisplayName = "远程控制平台命令执行端";
            this.serviceInstaller.Description = "远程控制平台命令执行端服务";
            this.serviceInstaller.StartType = ServiceStartMode.Automatic;

            this.Installers.AddRange(new Installer[] {
                this.serviceProcessInstaller,
                this.serviceInstaller});
        }
    }
}