using System;
using System.ServiceProcess;

namespace 远程控制平台命令执行端
{
    static class Program
    {
        static void Main()
        {
            ServiceBase[] ServicesToRun;
            ServicesToRun = new ServiceBase[] 
            { 
                new 远程控制平台命令执行端() 
            };
            ServiceBase.Run(ServicesToRun);
        }
    }
}