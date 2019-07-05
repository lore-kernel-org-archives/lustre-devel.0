From: Jacek Tomaka <jacekt@dug.com>
Date: Fri, 5 Jul 2019 09:13:59 +0800
Subject: [lustre-devel] Kernel panic - not syncing: LBUG:
 llite_mmap.c:71:our_vma()
In-Reply-To: <CAKVxXCXC90mHHABc1Hc+fYV6qRBMtXP7ALEz5PQDnYXBkwkSsw@mail.gmail.com>
References: <CAKVxXCWdEtazYGhKE2bF3sxWQxyr-ZQ2chHmUmdr+b-4P5fWvA@mail.gmail.com>
 <B3E35B12-C70F-40E7-8F2E-D9018614E430@whamcloud.com>
 <CAKVxXCXC90mHHABc1Hc+fYV6qRBMtXP7ALEz5PQDnYXBkwkSsw@mail.gmail.com>
Message-ID: <CAKVxXCVy=W1d3oMOS=WcpuvrOxmvS+yx7_WBfh_eH+LqMX5wkg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

https://jira.whamcloud.com/browse/LU-12508
Regards.
Jacek Tomaka


On Fri, Jul 5, 2019 at 9:07 AM Jacek Tomaka <jacekt@dug.com> wrote:
>
> Hi Andreas,
> Linux version 3.10.0-693.5.2.el7.x86_64 (builder at kbuilder.dev.centos.org) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-16) (GCC) ) #1 SMP Fri Oct 20 20:
> 32:50 UTC 2017
> Lustre: Lustre: Build Version: 2.10.1
> Intel(R) Xeon Phi(TM) CPU 7210 @ 1.30GHz
>
> It is reading in up to 256 threads. And writing 16 files in up to 16 threads.
>
> It is reproducible (but does not fail every time) on this particular machine, which might just be a particular network timing.
> I will try to reproduce it on another machine and get back to you if successful.
>
> Any ideas why this lock would have failed?
> A quick analysis shows that the only place where our_vma is called is lustre/llite/vvp_io.c:453, and it only acquires read lock:
> vvp_mmap_locks:
> 452                 down_read(&mm->mmap_sem);
>  453                 while((vma = our_vma(mm, addr, count)) != NULL) {
>  454                         struct dentry *de = file_dentry(vma->vm_file);
>  455                         struct inode *inode = de->d_inode;
>  456                         int flags = CEF_MUST;
>
> whereas our_vma has this:
> 70         /* mmap_sem must have been held by caller. */
> 71         LASSERT(!down_write_trylock(&mm->mmap_sem));
>
> So i guess if there are multiple threads in vvp_mmap_locks and more than one happen to acquire read_lock, or one of them acquires write lock then the other would fail, no?
> I will put these details into JIRA.
> Jacek Tomaka
>
> On Tue, Jul 2, 2019 at 3:45 PM Andreas Dilger <adilger@whamcloud.com> wrote:
>>
>> The best place to report Lustre bugs is at https://jira.whamcloud.com/
>>
>> Please include the Lustre version number you are running, and any details you can provide about what kind of IO the Java application was doing at the time, if this is even possible for Java :-). It looks like it is doing AIO?  Also, is this repeatable, or a one-time event?
>>
>> Cheers, Andreas
>>
>> > On Jul 2, 2019, at 01:20, Jacek Tomaka <jacekt@dug.com> wrote:
>> >
>> > Hello,
>> > I was wondering if you would be interested in the following failed assertion:
>> >
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: LustreError:
>> > 251884:0:(llite_mmap.c:71:our_vma()) ASSERTION(
>> > !down_write_trylock(&mm->mmap_sem) ) failed:
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: LustreError:
>> > 251884:0:(llite_mmap.c:71:our_vma()) LBUG
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: Pid: 251884, comm: java
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: #012Call Trace:
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc03d67ae>]
>> > libcfs_call_trace+0x4e/0x60 [libcfs]
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc03d683c>]
>> > lbug_with_loc+0x4c/0xb0 [libcfs]
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc116e66b>]
>> > our_vma+0x16b/0x170 [lustre]
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc11857f9>]
>> > vvp_io_rw_lock+0x409/0x6e0 [lustre]
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc0fbb312>] ?
>> > lov_io_iter_init+0x302/0x8b0 [lov]
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc1185b29>]
>> > vvp_io_write_lock+0x59/0xf0 [lustre]
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc063ebec>]
>> > cl_io_lock+0x5c/0x3d0 [obdclass]
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc063f1db>]
>> > cl_io_loop+0x11b/0xc90 [obdclass]
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc1133258>]
>> > ll_file_io_generic+0x498/0xc40 [lustre]
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc1133cdd>]
>> > ll_file_aio_write+0x12d/0x1f0 [lustre]
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffffc1133e6e>]
>> > ll_file_write+0xce/0x1e0 [lustre]
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffff81200cad>]
>> > vfs_write+0xbd/0x1e0
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffff8111f394>] ?
>> > __audit_syscall_entry+0xb4/0x110
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffff81201abf>]
>> > SyS_write+0x7f/0xe0
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: [<ffffffff816b5292>]
>> > tracesys+0xdd/0xe2
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel:
>> > 2019-07-02T01:45:11-05:00 nanny1926 kernel: Kernel panic - not syncing: LBUG
>> >
>> > Is there any other place where you would want it reported?
>> >
>> > --
>> > Jacek Tomaka
>> > Geophysical Software Developer
>> >
>> >
>> >
>> >
>> > DownUnder GeoSolutions
>> >
>> > 76 Kings Park Road
>> > West Perth 6005 WA, Australia
>> > tel +61 8 9287 4143
>> > jacekt at dug.com
>> > www.dug.com
>> > _______________________________________________
>> > lustre-devel mailing list
>> > lustre-devel at lists.lustre.org
>> > http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
>
>
> --
> Jacek Tomaka
> Geophysical Software Developer
>
>
>
>
> DownUnder GeoSolutions
>
> 76 Kings Park Road
> West Perth 6005 WA, Australia
> tel +61 8 9287 4143
> jacekt at dug.com
> www.dug.com



-- 
Jacek Tomaka
Geophysical Software Developer




DownUnder GeoSolutions

76 Kings Park Road
West Perth 6005 WA, Australia
tel +61 8 9287 4143
jacekt at dug.com
www.dug.com
