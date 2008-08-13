From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 13 Aug 2008 16:26:49 -0600
Subject: [Lustre-devel] Security issues
In-Reply-To: <1218652843.728.68.camel@JimsOSlap>
Message-ID: <C4C8BBC9.6CC0%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 8/13/08 12:40 PM, "James Hughes" <James.Hughes@Sun.COM> wrote:

> 
> 
> On Mon, 2008-08-11 at 13:33 -0600, Peter Braam wrote:
>>>>  >> 
>>>>  >> You do need to sign it and encrypt it - for multiple purposes, to
>>>> secure the
>>>>  >> wire transaction and for storage on the server.
>>>  > 
>>>  > Sorry I'm still a little confused. To be exactly clear, do you mean: In
>>>  > the future we'll use NASD-style protocol to secure the bulk data's wire
>>>  > transfer & storage on server; and for now we can simply leave the bulk
>>>  > data unprotected?
>>  
>>  No you need to be able to encrypt it.
>>  
>>  I'm just stating that if you the current solution (which gives privacy using
>>  GSS between client and OSS iirc) is going to be changed, then please change
>>  it in the correct way to accommodate re-using checksums and re-using the
>>  encrypted data for storage.  Doing either of these things twice is
>>  pointless.
> The NASD protocols do not allow for the encryption of the communications and
> the stored information to be the same. The key management for communications
> is well understood, but the key management for the stored information as
> defined by NASD requires the encryption of the stored information to be
> performed at the target.
> 
Why?  I don?t see a reason not to pursue this, even though it would not be
what NASD does. 

Using EAs there are easy key management systems (and more complex ones), and
we discussed an basic key server running inside the MDS?s with the tri-labs
who reacted quite positively.

Peter
> 
> 
>>  Probably there should be options not to do so as part of the configuration.
>>  
>>  Peter
>>  
>>  
> 

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080813/6e9fb6f4/attachment.htm>
