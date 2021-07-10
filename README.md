# CUDA_Passwd_Hacker
Break Password via CUDA Accelaration  

Final report is available at the [google_drive](https://drive.google.com/file/d/1n32RzQOVuH3vCGIoyuhSF2FaoDlXMx38/view?usp=sharing).
  
Usage:  
```bash  
make
sbatch TASK.sh  
make clean
```  
  
Example running result is:  
<pre>
Device Name: GeForce GTX 1080
Max Threads Per Block: 1024
The input hash stirng is: fa14d4fe2f19414de3ebd9f63d5c0169
Password Hacked: 759
Password cracked in [5.78797] ms.
</pre>

