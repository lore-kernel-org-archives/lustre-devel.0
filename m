From: Hashir Kidwai <hashir.kidwai@gmail.com>
Date: Fri, 9 Mar 2012 14:24:56 +0400
Subject: [Lustre-devel] Problems in installing Lustre Client in
	OpenSuse-12.1 Desktop
Message-ID: <CAGGZ7MLiAW1UgD-rJC6u5qbRyxDA3hBECjhb7qayA0q3aTpAFA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

I have posted this question on wc discussion forum but no response as of
yet, So I thought may be able to get some help from somebody from lustre
group or Mr. Adilger. Your help will highly be appreciated.

Thanks

Original Message:

Hello,
I have setup MGS and OSS on RHEL 6.2 without much problem. For client, when
I tried to install the rpms on OpenSuSe machine especially
lustre-client-module, it gave me tons of error. I think I need some extra
modules to support that. Here is the detailed output when I am trying to
install lustre-client-module.
At the end, I am also forwarding you the output of uname -a

Linux OpenSuSe-LustreClient 3.1.9-1.4-desktop..


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
rpm -ivh lustre-client-modules-2.1.56-2.6.32.36_0.5_default_
gbc5b01b.x86_64.rpm
error: Failed dependencies:
    kernel(default:kernel_sched) = 791cbfea55486180 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_sched) = a1e405adbae82281 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_params) = 7a2a1002ec0a9ea5 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_namei) = 30fe80ecd377a069 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_rcutree) = 8dd75c6c1874174c is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_mutex) = bb7ac1f8989b9c06 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:net_socket) = 0a59dbccc880b786 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_groups) = 959302627b7c04dd is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_semaphore) = c7a91f1e83a87245 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:mm_mempolicy) = dd136c5f866f6c61 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_module) = 880f9f607cb46b02 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:security_security) = 5e4f124bba3917ac is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:arch_x86_kernel_pci-dma) = 30a88bbabf8b66bc is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_wait) = e8f53b6be41ec496 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_spinlock) = c587e1beb0442cf5 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_notifier) = d919c1e55b213d77 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:mm_slab) = 9da45783fcbf9f27 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:mm_page-writeback) = 8e235d985265075d is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_time_timekeeping) = 8aaa55bd59b5c923 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:vmlinux) = 1b24bf78f91075a8 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_sysctl) = cfe229e69011b3f0 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_attr) = 101b09ed17b0d1a9 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:drivers_char_misc) = add3ab5011e8f953 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:arch_x86_kernel_x8664_ksyms_64) = d9438c557e2a3e44 is
needed by lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_rwsem) = ee607b7f03367958 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:mm_memory) = 51b4da23e3e0862b is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:net_core_net_namespace) = f0d903ca76dcece1 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_inode) = 24babd1a7925913a is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:mm_backing-dev) = 2169b86970b6e0f8 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:net_core_dev) = 25fc19fd2401d3cd is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:net_core_dev) = 5adcf4ca1d2aba8a is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:net_core_dev) = 8eae736efd27a783 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:drivers_infiniband_core_rdma_cm) = aa071d38cd11b1e1 is
needed by lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_dcache) = e434d61a4b926724 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_dcache) = ec172b9bcc287237 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:drivers_infiniband_core_ib_core) = b57a38097948c5c5 is
needed by lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:mm_filemap) = a3014e0cdcdb8bf3 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:mm_vmalloc) = 2ad90ab141f0dae4 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:arch_x86_kernel_setup_percpu) = c156e98ddda16670 is
needed by lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:lib_kernel_lock) = 33d46f710a4cfe1b is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_bio) = b54205c84b13a61e is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:mm_truncate) = b003dc367ed3a653 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_fs-writeback) = 7502f6ab6a5c5b66 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_fs-writeback) = ae3fb46c691f9a12 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_readdir) = 0e53cc462830d044 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_filesystems) = 67240f0d05f9e578 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:lib_scatterlist) = 9b045ae386606954 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_block_dev) = d2f3cd44d25afda3 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_block_dev) = fdb82054c673d6a6 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_seq_file) = 43506c78f6743a4d is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_xattr_acl) = 128b7054b0e8984b is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:mm_page_alloc) = dce861bddf347db6 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:mm_vmscan) = a5ca7732022b4e60 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_libfs) = e223757ef9dd5570 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_timer) = 5941964e823d8cb1 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_buffer) = 6826b544e30ab74b is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:crypto_crypto) = 611f46aa74d07b90 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:lib_bitmap) = 3f8c8adcfa3a36c9 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:block_blk-core) = 872969f718d39b5e is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_super) = 93ae87afd84e7ea2 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_kmod) = 6441ed6e66c21a1a is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:block_genhd) = 3572ca2b23c77dfc is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_bad_inode) = d8a4e490116aa67a is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_open) = 198debd2f21444b8 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:block_blk-settings) = 341a6647981e07ba is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_exit) = 6db9554c1d7b11eb is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:arch_x86_kernel_cpu_common) = 6d1b028ce9beaefc is needed
by lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:mm_swap) = 88a8162f9abe7d55 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_proc_proc) = 917b4d08ced27e78 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:net_ipv4_tcp) = cb5a71429fa93a60 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_cpu) = 9932da9563d69df3 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:mm_mmap) = b136a840b56d702c is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:drivers_char_random) = bf28b0770e45055d is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_cred) = d995cbe8fed0f8ab is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_time) = 5d18ecef0760c385 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_capability) = 21ae5dc41a677bfa is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_printk) = 3103c42dd6130248 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_splice) = 9dc8b91fc4a68a63 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:lib_crc32) = 6e9f350eb5653657 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_kthread) = 7029782ede167f56 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:net_core_sock) = bbcfc198996eada7 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_posix_acl) = d6a84241c9773c17 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_fs_struct) = 101435b45e21f61b is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:arch_x86_kernel_dumpstack_64) = ab0b225b5f6a80ec is
needed by lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_rcupdate) = 128c23e7c44bd405 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_file_table) = ede4f0edf5d79c89 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_namespace) = 32b147b5a738f364 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_panic) = 244b172e2d8fbf2e is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:arch_x86_kernel_setup) = 308273d3f2190526 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_kallsyms) = 2262b91c7b98f562 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:arch_x86_mm_physaddr) = 8a91ed3165f0c415 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:fs_locks) = 3da3278490dd705a is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:arch_x86_kernel_apic_nmi) = b6436addaebf1b79 is needed
by lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:kernel_signal) = 66c029933b86f1d3 is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
    kernel(default:init_main) = 3dedb5c02e81849e is needed by
lustre-client-modules-2.1.56-2.6.32.36_0.5_default_gbc5b01b.x86_64
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120309/a04a3136/attachment.htm>
