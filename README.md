# 获取镜像
## 从registry中拉取镜像：
```
$ sudo docker pull registry.cn-shanghai.aliyuncs.com/lxbcloud/kms-server:[镜像版本号]
```
其中[ImageId],[镜像版本号]请你根据自己的镜像信息进行填写。
## 注意您的网络环境：
>1. 从ECS推送镜像时，可以选择走内网，速度将大大提升，并且将不会损耗您的公网流量。
>1. 如果您申请的机器是在公共网络，请使用docker pull registry.cn-shanghai.aliyuncs.com 作为镜像名空间前缀
>1. 如果您申请的机器是在经典网络，请使用 registry-internal.cn-shanghai.aliyuncs.com 作为镜像名空间前缀
>1. 如果您申请的机器是在vpc网络的，请使用 registry-vpc.cn-shanghai.aliyuncs.com 作为镜像名空间前缀

## 使用docker tag重命名镜像：
```
[root@iZ11ci0wereZ ~]# sudo docker pull registry-internal.cn-shanghai.aliyuncs.com/lxbcloud/kms-server:latest
latest: Pulling from lxbcloud/kms-server
469cfcc7a4b3: Already exists 
bd6759ad1444: Pull complete 
Digest: sha256:c177365a95eced62e538440130510f6b7c11911a40463a9df69718cd046ae656
Status: Downloaded newer image for registry-internal.cn-shanghai.aliyuncs.com/lxbcloud/kms-server:latest
[root@iZ11ci0wereZ ~]# sudo docker images
REPOSITORY                                                       TAG                 IMAGE ID            CREATED             SIZE
registry-internal.cn-shanghai.aliyuncs.com/lxbcloud/kms-server   latest              5a623cefde02        12 minutes ago      199MB
centos                                                           latest              e934aafc2206        8 days ago          199MB
alpine                                                           latest              3fd9065eaf02        3 months ago        4.15MB
[root@iZ11ci0wereZ ~]# sudo docker tag 5a623cefde02 kms:latest
[root@iZ11ci0wereZ ~]# sudo docker images
REPOSITORY                                                       TAG                 IMAGE ID            CREATED             SIZE
kms                                                              latest              5a623cefde02        13 minutes ago      199MB
registry-internal.cn-shanghai.aliyuncs.com/lxbcloud/kms-server   latest              5a623cefde02        13 minutes ago      199MB
centos                                                           latest              e934aafc2206        8 days ago          199MB
alpine                                                           latest              3fd9065eaf02        3 months ago        4.15MB
[root@iZ11ci0wereZ ~]# sudo docker image rm registry-internal.cn-shanghai.aliyuncs.com/lxbcloud/kms-server
Untagged: registry-internal.cn-shanghai.aliyuncs.com/lxbcloud/kms-server:latest
Untagged: registry-internal.cn-shanghai.aliyuncs.com/lxbcloud/kms-server@sha256:c177365a95eced62e538440130510f6b7c11911a40463a9df69718cd046ae656
[root@iZ11ci0wereZ ~]# sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
kms                 latest              5a623cefde02        13 minutes ago      199MB
centos              latest              e934aafc2206        8 days ago          199MB
alpine              latest              3fd9065eaf02        3 months ago        4.15MB
[root@iZ11ci0wereZ ~]# sudo docker run -d -p 1688:1688 --restart=always --name kms kms
1dfd99cd1179bf566ab49db4e9a3e0c36d131543feba644f623252ce26c12d88
[root@iZ11ci0wereZ ~]# sudo netstat -anp | grep 1688
tcp6       0      0 :::1688                 :::*                    LISTEN      10716/docker-proxy  
[root@iZ11ci0wereZ ~]# sudo docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
1dfd99cd1179        kms                 "/bin/sh -c 'vlmcsd …"   20 seconds ago      Up 19 seconds       0.0.0.0:1688->1688/tcp   kms

```

# 延伸教学：

## KMS激活使用方法

一般来说，只要确保的下载的是VL批量版本并且没有手动安装过任何key，
你只需要使用管理员权限运行cmd执行一句命令就足够：

```
slmgr /skms yourip
```


然后去计算机属性或者控制面板其他的什么的地方点一下激活就好了。

当然，如果你懒得点，可以多打一句命令手动激活：

```
slmgr /ato
```

这句命令的意思是，马上对当前设置的key和服务器地址等进行尝试激活操作。

kms激活的前提是你的系统是批量授权版本，即VL版，一般企业版都是VL版，专业版有零售和VL版，家庭版旗舰版OEM版等等那就肯定不能用kms激活。一般建议从[http://msdn.itellyou.cn](http://msdn.itellyou.cn)上面下载系统
VL版本的镜像一般内置GVLK key，用于kms激活。如果你手动输过其他key，那么这个内置的key就会被替换掉，这个时候如果你想用kms，那么就需要把GVLK key输回去。首先，
到[https://technet.microsoft.com/en-us/library/jj612867.aspx](https://technet.microsoft.com/en-us/library/jj612867.aspx)
获取你对应版本的KEY
如果打不开下面有对应的

如果不知道自己的系统是什么版本，可以运行以下命令查看系统版本：

```
wmic os get caption
```

得到对应key之后，使用管理员权限运行cmd执行安装key：

```
slmgr /ipk xxxxx-xxxxx-xxxxx-xxxxx
```
然后跟上面说的一样设置kms服务器地址，激活。


## 一句命令激活OFFICE

首先你的OFFICE必须是VOL版本，否则无法激活。
找到你的office安装目录，比如

```
C:\Program Files (x86)\Microsoft Office\Office16
```

64位的就是

```
C:\Program Files\Microsoft Office\Office16
```

office16是office2016，office15就是2013，office14就是2010.

然后目录对的话，该目录下面应该有个OSPP.VBS。

接下来我们就cd到这个目录下面，例如：

```
cd C:\Program Files (x86)\Microsoft Office\Office16
```

然后执行注册kms服务器地址：

```
cscript ospp.vbs /sethst:kms.luody.info
```
/sethst参数就是指定kms服务器地址。

一般ospp.vbs可以拖进去cmd窗口，所以也可以这么弄：

```
cscript "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS" /sethst:kms.luody.info
```

一般来说，“一句命令已经完成了”，但一般office不会马上连接kms服务器进行激活，所以我们额外补充一条手动激活命令：

```
cscript ospp.vbs /act
```
 

如果提示看到successful的字样，那么就是激活成功了，重新打开office就好。

##　如果遇到报错，请检查：
>1. 你的系统/OFFICE是否是批量VL版本
>1. 是否以管理员权限运行CMD
>1. 你的系统/OFFICE是否修改过KEY/未安装GVLK KEY
>1. 检查你的网络连接
>1. 服务器繁忙，多试试（点击检查KMS服务是否可用）
>1. 根据出错代码自己搜索出错原因

# Windows GVLK密钥对照表（KMS激活专用）

 >以下key来源于微软官网：[https://technet.microsoft.com/en-us/library/jj612867.aspx](https://technet.microsoft.com/en-us/library/jj612867.aspx)


TODO:Windows Operating system

### Windows Server 2016
| Operating system edition          | KMS Client Setup Key          |
| --------------------------------- | ----------------------------- |
| Windows Server 2016 Datacenter    | CB7KF-BWN84-R7R2Y-793K2-8XDDG |
| Windows Server 2016 Standard      | WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY |
| Windows Server 2016 Essentials    | JCKRF-N37P4-C2D82-9YXRT-4M63B |

### Windows 10
| Operating system edition          | KMS Client Setup Key          |
| --------------------------------- | ----------------------------- |
| Windows 10 Core N                 | 3KHY7-WNT83-DGQKR-F7HPR-844BM |
| Windows 10 Core Country Specific  | PVMJN-6DFY6-9CCP6-7BKTT-D3WVR |
| Windows 10 Core Single Language   | 7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH |
| Windows 10 Professional           | W269N-WFGWX-YVC9B-4J6C9-T83GX |
| Windows 10 Professional N         | MH37W-N47XK-V7XM9-C7227-GCQG9 |
| Windows 10 Enterprise             | NPPR9-FWDCX-D2C8J-H872K-2YT43 |
| Windows 10 Enterprise N           | DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4 |
| Windows 10 Education              | NW6C2-QMPVW-D7KKK-3GKT6-VCFB2 |
| Windows 10 Education N            | 2WH4N-8QGBV-H22JP-CT43Q-MDWWJ |
| Windows 10 Enterprise 2015 LTSB   | WNMTR-4C88C-JK8YV-HQ7T2-76DF9 |
| Windows 10 Enterprise 2015 LTSB N | 2F77B-TNFGY-69QQF-B8YKP-D69TJ |
| Windows 10 Enterprise 2016 LTSB   | DCPHK-NFMTC-H88MJ-PFHPY-QJ4BJ |
| Windows 10 Enterprise 2016 LTSB N | QFFDN-GRT3P-VKWWX-X7T3R-8B639 |

### Windows 8.1 add Windows Server 2012 R2
| Operating system edition               | KMS Client Setup Key          |
| -------------------------------------- | ----------------------------- |
| Windows 8.1 Professional               | GCRJD-8NW9H-F2CDX-CCM8D-9D6T9 |
| Windows 8.1 Professional N             | HMCNV-VVBFX-7HMBH-CTY9B-B4FXY |
| Windows 8.1 Enterprise                 | MHF9N-XY6XB-WVXMC-BTDCT-MKKG7 |
| Windows 8.1 Enterprise N               | TT4HM-HN7YT-62K67-RGRQJ-JFFXW |
| Windows Server 2012 R2 Server Standard | D2N9P-3P6X9-2R39C-7RTCD-MDVJX |
| Windows Server 2012 R2 Datacenter      | W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9 |
| Windows Server 2012 R2 Essentials      | KNC87-3J2TX-XB4WP-VCPJV-M4FWM |

### Windows 8 add Windows Server 2012 
| Operating system edition                | KMS Client Setup Key          |
| --------------------------------------  | ----------------------------- |
| Windows 8 Professional                  | NG4HW-VH26C-733KW-K6F98-J8CK4 |
| Windows 8 Professional N                | XCVCF-2NXM9-723PB-MHCB7-2RYQQ |
| Windows 8 Enterprise                    | 32JNW-9KQ84-P47T8-D8GGY-CWCK7 |
| Windows 8 Enterprise N                  | JMNMF-RHW7P-DMY6X-RF3DR-X2BQT |
| Windows Server 2012                     | BN3D2-R7TKB-3YPBD-8DRP2-27GG4 |
| Windows Server 2012 N                   | 8N2M2-HWPGY-7PGT9-HGDD8-GVGGY |
| Windows Server 2012 Single Language     | 2WN2H-YGCQR-KFX6K-CD6TF-84YXQ |
| Windows Server 2012 Country Specific    | 4K36P-JN4VD-GDC6V-KDT89-DYFKP |
| Windows Server 2012 Server Standard     | XC9B7-NBPP2-83J2H-RHMBY-92BT4 |
| Windows Server 2012 MultiPoint Standard | HM7DN-YVMH3-46JC3-XYTG7-CYQJJ |
| Windows Server 2012 MultiPoint Premium  | XNH6W-2V9GX-RGJ4K-Y8X6F-QGJ2G |
| Windows Server 2012 Datacenter          | 48HP8-DN98B-MYWDG-T2DCC-8W83P |

## Windows 7 and Windows Server 2008 R2
| Operating system edition                | KMS Client Setup Key          |
| --------------------------------------  | ----------------------------- |
Windows 7 Professional |FJ82H-XT6CR-J8D7P-XQJJ2-GPDD4
Windows 7 Professional N |MRPKT-YTG23-K7D7T-X2JMM-QY7MG
Windows 7 Professional E |W82YF-2Q76Y-63HXB-FGJG9-GF7QX
Windows 7 Enterprise |33PXH-7Y6KF-2VJC9-XBBR8-HVTHH
Windows 7 Enterprise N |YDRBP-3D83W-TY26F-D46B2-XCKRJ
Windows 7 Enterprise E |C29WB-22CC8-VJ326-GHFJW-H9DH4
Windows Server 2008 R2 Web |6TPJF-RBVHG-WBW2R-86QPH-6RTM4
Windows Server 2008 R2 HPC edition |TT8MH-CG224-D3D7Q-498W2-9QCTX
Windows Server 2008 R2 Standard |YC6KT-GKW9T-YTKYR-T4X34-R7VHC
Windows Server 2008 R2 Enterprise |489J6-VHDMP-X63PK-3K798-CPX3Y
Windows Server 2008 R2 Datacenter |74YFP-3QFB3-KQT8W-PMXWJ-7M648
Windows Server 2008 R2 for Itanium-based Systems |GT63C-RJFQ3-4GMB6-BRFB9-CB83V

## Windows Vista and Windows Server 2008
操作系统       | KMS激活序列号
-------------------------------|------------------------------
Windows Vista Business |YFKBB-PQJJV-G996G-VWGXY-2V3X8
Windows Vista Business N |HMBQG-8H2RH-C77VX-27R82-VMQBT
Windows Vista Enterprise |VKK3X-68KWM-X2YGT-QR4M6-4BWMV
Windows Vista Enterprise N |VTC42-BM838-43QHV-84HX6-XJXKV
Windows Web Server 2008 |WYR28-R7TFJ-3X2YQ-YCY4H-M249D
Windows Server 2008 Standard |TM24T-X9RMF-VWXK6-X8JC9-BFGM2
Windows Server 2008 Standard without Hyper-V |W7VD6-7JFBR-RX26B-YKQ3Y-6FFFJ
Windows Server 2008 Enterprise |YQGMW-MPWTJ-34KDK-48M3W-X4Q6V
Windows Server 2008 Enterprise without Hyper-V |39BXF-X8Q23-P2WWT-38T2F-G3FPG
Windows Server 2008 HPC |RCTX3-KWVHP-BR6TB-RB6DM-6X7HP
Windows Server 2008 Datacenter |7M67G-PC374-GR742-YH8V4-TCBY3
Windows Server 2008 Datacenter without Hyper-V |22XQ2-VRXRG-P8D42-K34TD-G3QQC
Windows Server 2008 for Itanium-Based Systems |4DWFP-JF3DJ-B7DTH-78FJB-PDRHK


TODO:office

### Office 2019
| Product                       | GVLK                          |
| ----------------------------- | ----------------------------- |
| Office Professional Plus 2019 | NMMKJ-6RK4F-KMJVX-8D9MJ-6MWKP |
| Office Standard 2019          | 6NWWJ-YQWMR-QKGCB-6TMB3-9D9HK |
| Project Professional 2019     | B4NPR-3FKK7-T2MBV-FRQ4W-PKD2B |
| Project Standard 2019         | C4F7P-NCP8C-6CQPT-MQHV9-JXD2M |
| Visio Professional 2019       | 9BGNQ-K37YR-RQHF2-38RQ3-7VCBB |
| Visio Standard 2019           | 7TQNQ-K3YQQ-3PFH7-CCPPM-X4VQ2 |
| Access 2019                   | 9N9PT-27V4Y-VJ2PD-YXFMF-YTFQT |
| Excel 2019                    | TMJWT-YYNMB-3BKTF-644FC-RVXBD |
| Outlook 2019                  | 7HD7K-N4PVK-BHBCQ-YWQRW-XW4VK |
| PowerPoint 2019               | RRNCX-C64HY-W2MM7-MCH9G-TJHMQ |
| Publisher 2019                | G2KWX-3NW6P-PY93R-JXK2T-C9Y9V |
| Skype for Business 2019       | NCJ33-JHBBY-HTK98-MYCV8-HMKHJ |
| Word 2019                     | PBX3G-NWMT6-Q7XBW-PYJGG-WXD33 |
