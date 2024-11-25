// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./errors/MatrixErrors.sol";

contract Matrix3DNFT is ERC1155URIStorage,Ownable {
    address public Matrix3D;
    string public constant RedPillMetadata = "https://ipfs.io/ipfs/bafkreiab7onazgctir3zx6sbluxlaw7bg6qymzuxooe42qjggns545wski";
    string public constant BluePillMetadata = "https://ipfs.io/ipfs/bafkreiab7onazgctir3zx6sbluxlaw7bg6qymzuxooe42qjggns545wski";

    modifier OnlyMatrixGame(address _matrix3D) {
        if (Matrix3D != _matrix3D)
            revert MatrixErrors.Matrix3DErrors(
                MatrixErrors.Errors.AccessDenied
            );

        _;
    }

    constructor(string memory _url) ERC1155(_url) Ownable(msg.sender){}
    function initailizeMatrix(address _matrix3D) public onlyOwner {
        Matrix3D = _matrix3D;
    }
    function mint(
        address _user,
        uint _token_id,
        uint32 _count
    ) public OnlyMatrixGame(msg.sender) {
        _mint(_user, _token_id, uint(_count), abi.encode(0));
        string memory uri=_token_id%2==0?RedPillMetadata:BluePillMetadata;
        _setURI(_token_id, uri);
    }
}
