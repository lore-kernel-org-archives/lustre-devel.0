From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Mon, 28 Sep 2009 21:04:41 -0400
Subject: [Lustre-devel] File offsets with multiple clients
In-Reply-To: <20090925194903.F379E20593C1@hailoo.com>
References: <20090925194903.F379E20593C1@hailoo.com>
Message-ID: <D0BBB36C-3D59-40AA-AA64-06EA5B6347B5@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Sep 25, 2009, at 3:49 PM, office at hailoo.com wrote:

> When a client obtains a file descriptor to a file on a Lustre file  
> system, is the file offset pointer shared among any connected  
> clients, or is it only meaningful to a single client?

It's even stricter than that. the pointer is per file-descriptor (the  
one you get from open(2) system call).
> For example, given the file "foo.txt" on a Lustre file system,  
> suppose there are 2 clients with an open file descriptor to  
> "foo.txt".  If Client1 calls lseek and then write, will this affect  
> the file offset position of Client2?  Or is the application  
> responsible for synchronizing file access in this case?
>

No, since both applications on both clients did separate opens, their  
current file position pointer is separate.
The answer does not change even if both processes were running on the  
same client.
This is by design and is mandated by POSIX.

Bye,
     Oleg
