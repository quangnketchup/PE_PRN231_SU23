cd WebApi
cd Controllers
#PetsController ================================================================================ TODO
@"
using BusinessObject.Authortication;
using BusinessObject.Model;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OData.Query;
using Microsoft.AspNetCore.OData.Routing.Controllers;
using Repositories;

namespace WebApi.Controllers
{
    [PermissionAuthorize("Staff")]
    public class PetsController : ODataController
    {
        private readonly IPetRepository _petRepository;

        public PetsController(IPetRepository petRepository)
        {
            _petRepository = petRepository;
        }

        [EnableQuery]
        public IActionResult Get()
        {
            return Ok(_petRepository.GetAll());
        }

        [EnableQuery]
        public ActionResult<Pet> Get([FromRoute] int key)
        {
            var pet = _petRepository.Get(key);
            if(pet == null)
            {
                return NotFound("Pet Id Not Found!");
            }
            return Ok(pet);
        }

        public IActionResult Post([FromBody] Pet pet)
        {
            _petRepository.Add(pet);
            return Ok("Add Successfully!");
        }

        public IActionResult Delete([FromRoute] int key)
        {
            _petRepository.Delete(key);
            return Ok("Delete Successfully!");
        }
        public IActionResult Put([FromRoute] int key, [FromBody] Pet pet)
        {
            _petRepository.Update(pet);
            return Ok("Update Successfully!");
        }
    }
}
"@ | Set-Content -Path "PetsController.cs"
cd ..
cd ..