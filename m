From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Tue, 12 Feb 2008 15:24:34 -0800
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <20080212172321.GQ3029@webber.adilger.int>
References: <47AAE307.9040305@cea.fr> <47ACC71C.7050808@sun.com>
	<47B062BA.1070809@cea.fr> <47B0B0FF.7060805@sun.com>
	<20080212035557.GP3029@webber.adilger.int>
	<026801c86d67$01a0beb0$0281a8c0@ebpc> <47B1BA52.8040304@cea.fr>
	<20080212172321.GQ3029@webber.adilger.int>
Message-ID: <47B22AB2.9010109@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> On Feb 12, 2008  16:25 +0100, Aurelien Degremont wrote:
>   
>> Eric Barton a ?crit :
>>     
>>> Sorry if these questions duplicates previous debate.
>>>
>>> Have I understood correctly that the design allows individual objects
>>> within a lustre file (i.e. stripes?) to be purged independently?
>>>
>>> If so why is this needed?
>>>
>>> I would have thought that when you purge a file, you need only record
>>> the purged extent as an attribute of the whole lustre file and punch
>>> its stripes to free the space.  Am I missing a use case?
>>>       
>> Since the beginning CFS required this feature. It seems a lab ask for 
>> it. I do not know who. Unfortunately we have no use case for what they 
>> want to do with this.
>> I'm wondering if their need could not be met with other features like 
>> the internal Lustre migration...
>>     
>
> That is my understanding also - I believe one of the Labs wanted this
> (to be able to do HSM on a per-stripe basis instead of a per-file basis).
>   
This doesn't make any sense to me.  Layouts may change;
a stripe on one filesystem may not correspond to a stripe on a replica 
of the filesystem;
exposing stripes to user apps is a bad idea.

I'm going to propose what I think we need:
1. Punch a single, arbitrary byte range from the middle of a file (thus
    leaving beginning and end for file type, icons, filesize.
2. No other arbitrary punch patterns.
3. The punched range is stored on the MDT alone.
4. Once punched, the OST may forget about any fully-punched stripes it
    used to hold.
5. Clients must take a layout lock (CR) when they retrieve the layout from
    the MDT.  If the MDT punches from the middle, it revokes the layout 
lock,
    and clients must re-enqueue it for further read/write on the file.  
The MDT
    is the sole keeper of the layout, and it must be protected by a lock.
6. Client access within a punched range results in an RPC to the MDT.  The
    MDT decides where to put the restored data, organizes the restoration
    (via the coordinator), and rewrites the layout (under lock, of course).
    Client gets the new layout, and can contact the appropriate OST.
