From: Robert Read <rread@sun.com>
Date: Tue, 08 Dec 2009 10:38:01 -0800
Subject: [Lustre-devel] loadgen improvements
In-Reply-To: <3ed212d00912050521l530cefc4oc6c44afce48faaa@mail.gmail.com>
References: <3ed212d00912050521l530cefc4oc6c44afce48faaa@mail.gmail.com>
Message-ID: <21235BEC-1B37-49E5-ADB2-885B154DCB4C@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Yury,

Sounds interesting; I'm happy to see loadgen will be improved.  Please create a bug in bugzilla.lustre.org and attach your patch so we can add it to the queue. 

thanks,
robert

On Dec 5, 2009, at 05:21 , Yuriy Umanets wrote:

> hello Lustre hackers,
> 
> ClusterStor would like to start doing real contributions to Lustre stability and popularity. First off, we would like to improve loadgen utility, written by Nathan Rutman. We think loadgen is a really good tool for testing and what is not less important, it is implemented right way from architecture point of view.
> 
> However, these days it has number of issues:
> 1. Wrong stack size for threads, that results in segfault (find the patch in attachment);
> 2. Little locking issues (push_kid() function);
> 3. Absence of striping functionality, it only may create load on one OST/ECHO server.
> 
> We plan to add striping functionality to loadgen. General idea is to use LOV module, which already has all the needed code. Loadgen itself and echo_client also have related code, so it seems this functionality was planned anyway, though it's not working currently. Currently an attempt to attach to a LOV results in assertion failures.
> 
> Let's discuss these matters. The way we're going to implement this may be roughly expressed as follows:
> 
> 1. Attach to LOV device in loadgen, using "device" command. To do so we need to construct new LOV instance, used by loadgen only, as we cannot use LOV instance used by LLITE. This requires changes to handling function for command "device". It should accept more than one OST target;
> 
> 2. Stripe size and stripe count of new LOV instance should also be specified while constructing it using "device" command;
> 
> 3. Setup of virtual clients should take into account that LOV may be used as a target. In this case attaching dedicated OSCs to created echo_client's is not needed.
> 
> 4. In order to be able to run thousands of threads, we need the following:
>  - reasonable stack size for threads;
>  - change 8192 OBD number limit to something more reasonable.
> 
> 5. Load itself is created in the way being currently used - via obd_brw().
> 
> Thanks.
> 
> -- 
> umka
> <loadgen-stacksize.patch>_______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
