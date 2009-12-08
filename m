From: Nic Henke <nic@cray.com>
Date: Tue, 08 Dec 2009 14:01:51 -0600
Subject: [Lustre-devel] loadgen improvements
In-Reply-To: <5250C925-EDB4-48FA-AD3C-AC37B212BB2B@sun.com>
References: <3ed212d00912050521l530cefc4oc6c44afce48faaa@mail.gmail.com>
	<5250C925-EDB4-48FA-AD3C-AC37B212BB2B@sun.com>
Message-ID: <4B1EB0AF.4060601@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> Hello Yuriy,
>
>   
>> 5. Load itself is created in the way being currently used - via  
>> obd_brw().
>>     
>
>
> Actually, the real code does not use obd_brw() directly anymore, but  
> rather obd_brw_async().  I think Nic Henke submitted a patch to change  
> that, I'm not sure of the current status of that patch.
>
>   
This is Bug 18225 - looks like it was landed to 1.6.8+ and 1.8.1+, but 
was dropped from HEAD as there is more work that'd need to be done there.

Nic
